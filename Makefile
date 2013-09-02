%: %.rs
	rustc $< -o $@

test-%: %.rs
	rustc $< --test -o $@

run-%: %.rs
	rust run $<

run-test-%: %.rs
	rust test $<
  
clean:
	rm -rf *.dSYM && find . -type f -perm +111 | xargs rm -f
