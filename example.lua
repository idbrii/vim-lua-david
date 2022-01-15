local self = {
    kitchen = {},
}

if false then
    if true then
        local data = self.kitchen
            :getContents()
            :getCheese()
            :enjoyCheese(self
                :mouth()
                :open()
                :extendTongue())
            :eatCheese({fn = function()
                return 10
            end})
        data = self.kitchen
            :getContents()
            :getCheese()
            :digestCheese(function()
                local a = (1 + 2
                    + 3
                    * (10
                    + 20))
                return a
            end, function()

                return function()
                    return 3+3
                end
            end)

        -- These should display as errors.
        self.Func()
        self.IsInCommentOrString(10)

        -- These are not errors.
        self.func()
        self.is_in_comment_or_string(10)
        self:Func()
        self:IsInCommentOrString(10)
    end
end

