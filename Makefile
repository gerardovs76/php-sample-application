install-dev: composer.phar
	./composer.phar install
	ln --symbolic --no-dereference --force config-dev config

composer.phar:
	curl -sS https://getcomposer.org/composer.phar -o composer.phar
	chmod u+x composer.phar
