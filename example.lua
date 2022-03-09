local Person = {
	kitchen = {},
	none = nil,
}

local BIGONE = "define"

local b = true
local i = 10
local f = 10.0
local x = 19.9e19
local t = {
	x = 19.9e19,
}

function Person:doStuff()
	if false and true or (false ~= true) then
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
				:getContents(data)
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
		local d = self.kitchen
			:getContents()
			:getCheese(function()
				return 10
			end)
		return d
	end
	local d = self.kitchen
		:getContents()
		:getCheese()
	return d
end

local p = self.input:getActiveControls(
	5,
	10,
	function(value)
		local name_remap = {
			axis = {
				left = "Left Stick",
				["triggerright+"] = "Right Trigger",
			},
		}
		return name_remap[value] or value
	end)
print(p)

data = self.kitchen
	:digestCheese(function()
		return 1
	end)
self:Func()

data = self.kitchen
	:eatCheese({fn = function()
		return 10
	end})
	:digestCheese()

if hasTaste()
	and lovesTaste()
	and gottaHaveIt()
then
	eatIt()
end


-- Error highlight
t[0] = 39
i += 39
b = b != false
local e = ("hello"):gsub("\w")
