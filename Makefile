default: build run

run: fizzbuzz
	./fizzbuzz

test: test-fizzbuzz
	./test-fizzbuzz

fizzbuzz: fizzbuzz.rs
	rustc fizzbuzz.rs

test-fizzbuzz: fizzbuzz.rs
	rustc fizzbuzz.rs --test -o test-fizzbuzz

clean:
	rm -rf *.dSYM && find . -type f -perm +111 | xargs rm -f
