.PHONY: install ssh

install: ssh
	ln -fs `pwd`/ghci ~/.ghci
	ln -fs `pwd`/vimrc ~/.vimrc
	ln -fs `pwd`/tmux.conf ~/.tmux.conf

ssh:
	mkdir -p ~/.ssh
	ln -fs `pwd`/ssh_config ~/.ssh/config
