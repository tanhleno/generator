program calculator:

sum: takes a, b: integer returns integer
    pop a + b
end

sub: takes a, b: integer returns integer
    pop a - b
end

mult: takes a, b: integer returns integer
    pop a * b
end

div: takes a, b: integer returns integer
    pop a / b
end

main:
    x, y, result, option: integer;
    output "Inform two integer:";
    input x;
    input y;

    output "Select one option:";
    output "1) Add "      . x . " by " . y;
    output "2) Subtract " . x . " by " . y;
    output "3) Multiply " . x . " by " . y;
    output "4) Divide "   . x . " by " . y;

    when case option = 1:
        let result = sum(x, y)
    end
    case option = 2:
        let result = sub(x, y)
    end
    case option = 3:
        let result = mult(x, y)
    end
    case option = 4:
        let result = div(x, y)
    end
    otherwise:
        output "Unknown option!"
    end;

    output "The result is " . result
end