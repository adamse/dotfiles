.PHONY: install ssh

install: ssh
	ln -s `pwd`/ghci ~/.ghci
	ln -s `pwd`/vimrc ~/.vimrc
	ln -s `pwd`/tmux.conf ~/.tmux.conf

ssh:
	mkdir -p ~/.ssh
	ln -s `pwd`/ssh_config ~/.ssh/config
