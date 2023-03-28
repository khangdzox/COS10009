# Recursive Factorial

# Complete the following
def factorial(n)
  return 2 if n == 2
  return n * factorial(n-1)
end

# Add to the following code to prevent errors for ARGV[0] < 1 and ARGV.length < 1
def main
  if ARGV.length != 1 or ARGV[0].to_i < 1 
    puts("Incorrect argument - need a single argument with a value of 0 or more.\n")
  else
    puts factorial(ARGV[0].to_i)
  end
end

main