%: %.rs
	rustc $< -o $@

test-%: %.rs
	rustc $< --test -o $@

clean:
	rm -rf *.dSYM && find . -type f -perm +111 | xargs rm -f
