local NONE = newproxy(true)

return {
    Dictionary = {
        join = function(...)
            local new = {}

            for i = 1, select("#", ...) do
                local t = select(i, ...)
                for k, v in pairs(t) do
                    if v ~= NONE then
                        new[k] = v
                    else
                        new[k] = nil
                    end
                end
            end

            return new
        end,
        keys = function(t)
            local new = {}

            for k, _ in pairs(t) do
                table.insert(new, k)
            end

            return new
        end,
    },
    List = {
        toSet = function(t)
            local new = {}

            for _, v in pairs(t) do
                new[v] = true
            end

            return new
        end,
        join = function(...)
            local new = {}

            for i = 1, select("#", ...) do
                local t = select(i, ...)
                for _, v in pairs(t) do
                    table.insert(new, v)
                end
            end

            return new
        end,
    },
    None = NONE,
}
