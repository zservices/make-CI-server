.PHONY: all clean test

all: zmake.1 make-server.1

clean:
	rm -f zmake.1 make-server.1

test:
	man ./zmake.1 >/dev/null;2>&1
	man ./make-server.1 >/dev/null;2>&1
	@printf "No errors found\\n"

zmake.1: zmake.md
	pandoc zmake.md -s -t man > zmake.1

make-server.1: make-server.md
	pandoc make-server.md -s -t man > make-server.1
