.PHONY: all clean test pandoc

all: pandoc zmake.1 make-server.1

pandoc:
	@command type 2>/dev/null >&2 pandoc || { \
	printf "\\e[1;34mpandoc\\e[1;35m not found, cannot create man pages.\\n\\e[0m"; \
	printf "Install e.g.: with: pip install pandoc.\\n"; \
	false; }

clean:
	rm -f zmake.1 make-server.1

test:
	pandoc --fail-if-warnings zmake.md >/dev/null
	pandoc --fail-if-warnings make-server.md >/dev/null
	@printf "No errors found\\n"

zmake.1: zmake.md
	pandoc zmake.md -s -t man > zmake.1

make-server.1: make-server.md
	pandoc make-server.md -s -t man > make-server.1
