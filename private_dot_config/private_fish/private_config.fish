if status is-interactive
    # Commands to run in interactive sessions can go here
end


alias cmdiff='chezmoi diff'

function cmdiff
	chezmoi diff
end
