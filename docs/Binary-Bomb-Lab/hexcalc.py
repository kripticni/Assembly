def strip_hex_prefix(s):
    if s.startswith("0x"):
        return s[2:]
    return s


def main():
    while True:
        try:
            stdin = input(">> ").split()
            if len(stdin) == 1:
                print(f"dec = {int(stdin[0],16)}")
                continue
            if len(stdin) != 3:
                print("Usage: <hex> <operator> <hex>, e.g., 0x10 + 0x5")
                continue

            n1 = int(strip_hex_prefix(stdin[0]), 16)
            n2 = int(strip_hex_prefix(stdin[2]), 16)
            operation = stdin[1]

            if operation == "+":
                res = hex(n1 + n2)
            elif operation == "-":
                res = hex(n1 - n2)
            elif operation == "*":
                res = hex(n1 * n2)
            elif operation == "/":
                if n2 == 0:
                    print("Error: division by zero")
                    continue
                res = hex(n1 // n2)
            else:
                print(f"Unknown operation: {operation}")
                continue

            print(f"= {res}")

        except Exception as e:
            print(f"Error: {e}")


main()
