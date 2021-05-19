const _ARFF_SPACE       = UInt8(' ')
const _ARFF_COMMENT     = UInt8('%')
const _ARFF_AT          = UInt8('@')
const _ARFF_SEP         = UInt8(',')
const _ARFF_NEWLINE     = UInt8('\n')
const _ARFF_NOMSTART    = UInt8('{')
const _ARFF_NOMEND      = UInt8('}')
const _ARFF_ESC         = UInt8('\\')
const _ARFF_MISSING     = UInt8('?')
const _ARFF_RELMARK     = UInt8('\'')

function readARFF(p::String)
    open(p, "r") do io
        lines = readlines(io)
        for i in 1:length(lines)
            line = lines[i]
            # If not empty line or comment
            if !isempty(line) && UInt8(line[1]) != _ARFF_COMMENT
                sline = split(line, " ")
                # println(sline[1][1])
                # If the first symbol is @
                if UInt8(sline[1][1]) == _ARFF_AT
                    # If @relation
                    if sline[1][2:end] == "relation"
                        println(i)
                        println("Relation: " * sline[2])
                    end
                end
            end
            #error(1)
        end
    end
end

# for (i, x) in enumerate([1,2,3,4])
#     println(i, " ", x)
#     i=3
# end

# @grammar begin
#     S   = UnivGlobal(F) | ExistGlobal(F)
#     F   = UnivL(implies(F,F))
#     F   = ExistL(and(F,F))
#     F   = implies(F,F)
#     F   = and(F,F)
#     F   = f(A)
# end
#
# @grammar begin
#     S   = ExistentialIntervalRelation{:L}(and(F,F))
#     F   = f(A)
# end
