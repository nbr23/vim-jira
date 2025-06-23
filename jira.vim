if exists('g:loaded_jira_plugin')
    finish
endif
let g:loaded_jira_plugin = 1

if !exists('g:jira_script_path')
    let g:jira_script_path = '/usr/local/bin/vim-jira.py'
endif

if !exists('g:jira_search_mapping')
    let g:jira_search_mapping = '<leader>j'
endif

highlight default JiraBug ctermfg=red guifg=Red
highlight default JiraStory ctermfg=green guifg=Green
highlight default JiraTask ctermfg=blue guifg=Blue
highlight default JiraEpic ctermfg=magenta guifg=Magenta
highlight default JiraSubtask ctermfg=cyan guifg=Cyan
highlight default JiraUnknown ctermfg=yellow guifg=Yellow
highlight default JiraBugBold ctermfg=red guifg=Red cterm=bold gui=bold
highlight default JiraStoryBold ctermfg=green guifg=green cterm=bold gui=bold
highlight default JiraTaskBold ctermfg=blue guifg=Blue cterm=bold gui=bold
highlight default JiraEpicBold ctermfg=magenta guifg=Magenta cterm=bold gui=bold cterm=bold gui=bold
highlight default JiraSubtaskBold ctermfg=cyan guifg=Cyan cterm=bold gui=bold
highlight default JiraUnknownBold ctermfg=yellow guifg=Yellow cterm=bold gui=bold

function! JiraSearch()
    let search_term = input('JIRA search: ')
    if empty(search_term)
        return
    endif

    let jira_output = system(g:jira_script_path . ' "' . escape(search_term, '"') . '"')

    if v:shell_error != 0
        echo "Error calling JIRA API: " . jira_output
        return
    endif

    try
        let jira_data = json_decode(jira_output)
    catch
        echo "Error parsing JIRA response"
        return
    endtry

    if empty(jira_data) || type(jira_data) != type([])
        echo "No JIRA tickets found"
        return
    endif

    let choices = []
    let ticket_details = []
    let index = 1

    for ticket in jira_data
        let key = get(ticket, 'key', 'UNKNOWN')
        let summary = get(ticket, 'summary', 'No summary')
        let issuetype = get(ticket, 'issuetype', 'Unknown')
        let status = get(ticket, 'status', 'Unknown')
        let assignee = get(ticket, 'assignee', 'Unassigned')
        let assignedToMe = get(ticket, 'assignedToMe', 0)

        let display_summary = len(summary) > 80 ? summary[:77] . '...' : summary
        let choice_text = printf('%d. %s [%s] (%s) - %s%s', index, key, issuetype, status, display_summary, assignee != 'Unassigned' ? ' | ' . assignee : '')

        call add(choices, choice_text)
        call add(ticket_details, {'text': choice_text, 'issuetype': issuetype, 'key': key, 'summary': summary, 'status': status, 'assignee': assignee, 'assignedToMe': assignedToMe})
        let index += 1
    endfor

    redraw
    echo "JIRA Search Results:"
    echo "==================="
    for detail in ticket_details
        let l:issueTypeNormalized = tolower(detail.issuetype)
        if l:issueTypeNormalized ==# 'bug'
            if detail.assignedToMe
                echohl JiraBugBold
            else
                echohl JiraBug
            endif
        elseif l:issueTypeNormalized ==# 'story'
            if detail.assignedToMe
                echohl JiraStoryBold
            else
                echohl JiraStory
            endif
        elseif l:issueTypeNormalized ==# 'task'
            if detail.assignedToMe
                echohl JiraTaskBold
            else
                echohl JiraTask
            endif
        elseif l:issueTypeNormalized ==# 'epic'
            if detail.assignedToMe
                echohl JiraEpicBold
            else
                echohl JiraEpic
            endif
        elseif l:issueTypeNormalized =~# 'sub-task' || l:issueTypeNormalized =~# 'subtask'
            if detail.assignedToMe
                echohl JiraSubtaskBold
            else
                echohl JiraSubtask
            endif
        else
            if detail.assignedToMe
                echohl JiraUnknownBold
            else
                echohl JiraUnknown
            endif
        endif
        echo detail.text
        echohl None
    endfor
    echo ""

    if len(choices) == 0
        echo "No tickets found for the search term"
        return
    endif
    let selection = '0'
    if len(choices) == 1
        let selection = '1'
    else
        let selection = input('Select ticket (1-' . len(choices) . ') or q to quit: ')
    endif

    if selection ==# 'q' || selection ==# 'Q'
        echo "Search cancelled"
        return
    endif

    let selection_num = str2nr(selection)

    if selection_num < 1 || selection_num > len(choices)
        echo "Invalid selection"
        return
    endif

    let ticket_key = ticket_details[selection_num - 1].key
    execute "normal! i" . ticket_key . " - "

    echo "Selected " . ticket_details[selection_num - 1].key . ": " . ticket_details[selection_num - 1].summary
endfunction

command! JiraSearch call JiraSearch()

execute 'nnoremap ' . g:jira_search_mapping . ' :call JiraSearch()<CR>'
