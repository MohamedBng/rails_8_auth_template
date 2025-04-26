.PHONY: lint test

lint:
	bundle exec rubocop -a

test:
	bundle exec rspec
