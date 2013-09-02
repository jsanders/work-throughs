%: %.rs
	rustc $< -o bin/$@

test-%: %.rs
	rustc $< --test -o bin/$@

run-%: %.rs
	rust run $<

run-test-%: %.rs
	rust test $<

clean:
	rm -rf *.dSYM && find . -type f -perm +111 | xargs rm -f
