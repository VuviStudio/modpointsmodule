-- ModpointsModule.luau

local HttpService = game:GetService("HttpService")

local ModpointsModule = {}

local API_BASE_URL = "https://modmpointsapoc.vercel.app"
local API_ENDPOINTS = {
	HEALTH = "/health",
	GET_ALL = "/api/modpoints",
	GET_USER = "/api/modpoints/%s", 
	ADD_USER = "/api/modpoints/%s", 
	SET_USER = "/api/modpoints/%s", 
	REMOVE_USER = "/api/modpoints/%s"
}

local function makeRequest(method, url, data)
	local success, result = pcall(function()
		local request = {
			Url = url,
			Method = method,
			Headers = {
				["Content-Type"] = "application/json"
			}
		}
		
		if data then
			request.Body = HttpService:JSONEncode(data)
		end
		
		return HttpService:RequestAsync(request)
	end)
	
	if not success then
		warn("HTTP request failed:", result)
		return nil, "Request failed: " .. tostring(result)
	end
	
	if result.Success then
		local success, decoded = pcall(function()
			return HttpService:JSONDecode(result.Body)
		end)
		
		if success then
			return decoded
		else
			return nil, "Failed to decode response"
		end
	else
		return nil, "HTTP error: " .. tostring(result.StatusCode) .. " - " .. tostring(result.Body)
	end
end

function ModpointsModule.health()
	local response, error = makeRequest("GET", API_BASE_URL .. API_ENDPOINTS.HEALTH)
	
	if not response then
		return false, error
	end
	
	return response.status == "healthy", response
end

function ModpointsModule.getAll()
	local response, error = makeRequest("GET", API_BASE_URL .. API_ENDPOINTS.GET_ALL)
	
	if not response then
		return nil, error
	end
	
	return response
end

function ModpointsModule.check(discordUserId)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	local url = string.format(API_BASE_URL .. API_ENDPOINTS.GET_USER, tostring(discordUserId))
	local response, error = makeRequest("GET", url)
	
	if not response then
		return nil, error
	end
	
	if response.success then
		return response.data.points or 0, response.data
	else
		return nil, "Failed to get modpoints for user " .. tostring(discordUserId)
	end
end

function ModpointsModule.add(discordUserId, amount)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	amount = amount or 1
	
	local url = string.format(API_BASE_URL .. API_ENDPOINTS.ADD_USER, tostring(discordUserId))
	local data = {
		points = amount
	}
	
	local response, error = makeRequest("POST", url, data)
	
	if not response then
		return nil, error
	end
	
	if response.success then
		return response.data.points, response.data
	else
		return nil, "Failed to add modpoints for user " .. tostring(discordUserId)
	end
end

function ModpointsModule.set(discordUserId, amount)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	if not amount or amount < 0 then
		return nil, "Valid amount is required"
	end
	
	local url = string.format(API_BASE_URL .. API_ENDPOINTS.SET_USER, tostring(discordUserId))
	local data = {
		points = amount
	}
	
	local response, error = makeRequest("PUT", url, data)
	
	if not response then
		return nil, error
	end
	
	if response.success then
		return response.data.points, response.data
	else
		return nil, "Failed to set modpoints for user " .. tostring(discordUserId)
	end
end

function ModpointsModule.remove(discordUserId, amount)
	if not discordUserId then
		return nil, "Discord user ID is required"
	end
	
	local url = string.format(API_BASE_URL .. API_ENDPOINTS.REMOVE_USER, tostring(discordUserId))
	local data = {}
	
	if amount then
		data.points = amount
	end
	
	local response, error = makeRequest("DELETE", url, data)
	
	if not response then
		return nil, error
	end
	
	if response.success then
		return response.data.points, response.data
	else
		return nil, "Failed to remove modpoints for user " .. tostring(discordUserId)
	end
end

ModpointsModule.get = ModpointsModule.check

return ModpointsModule
