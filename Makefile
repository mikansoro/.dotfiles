init:
	git submodule update --init --recursive

install:
	stow --verbose --target=$HOME --restow files/*

delete:
	stow --verbose --target=$HOME --delete files/*
