# ModpointsModule 



## Features

- **Check modpoints** for any Discord user ID
- **Add modpoints** with customizable amounts
- **Set exact modpoints** values
- **Remove modpoints** (partial or complete)
- **API health monitoring**
- **Get comprehensive statistics**
- **Robust error handling**
- **Automatic player detection**

## Quick Start

### Installation

1. **Download the ModpointsModule** to your  project
2. **Place the module** in ReplicatedStorage:
   ```
   Game
   └── ReplicatedStorage
       └── ModpointsModule (ModuleScript)
   ```
3. **Enable HTTP requests** in your game settings:
   - Go to Game Settings → Security
   - Enable "Allow HTTP Requests"

### Basic Usage

```lua
-- Server-side usage
local ModpointsModule = require(game.ReplicatedStorage.ModpointsModule)

-- Check modpoints for a Discord user
local points, data = ModpointsModule.check("123456789")
if points then
    print("User has", points, "modpoints")
else
    print("Error:", data)
end

-- Add 5 modpoints
local newTotal = ModpointsModule.add("123456789", 5)
print("New total:", newTotal)

-- Set exact amount
ModpointsModule.set("123456789", 10)

-- Remove 3 modpoints
local remaining = ModpointsModule.remove("123456789", 3)
```

## API Reference

### Core Functions

#### `ModpointsModule.check(discordUserId)`
Retrieves the current modpoints for a Discord user.

**Parameters:**
- `discordUserId` (string) - The Discord user ID to check

**Returns:**
- `points` (number) - The number of modpoints the user has
- `data` (table) - Full response data from the API

**Example:**
```lua
local points, data = ModpointsModule.check("123456789")
if points then
    print("User has", points, "modpoints")
    print("User data:", data)
else
    print("Error:", data)
end
```

#### `ModpointsModule.add(discordUserId, amount)`
Adds modpoints to a Discord user's account.

**Parameters:**
- `discordUserId` (string) - The Discord user ID
- `amount` (number, optional) - Amount to add (defaults to 1)

**Returns:**
- `newTotal` (number) - The new total modpoints
- `data` (table) - Full response data from the API

**Example:**
```lua
-- Add 5 modpoints
local newTotal, data = ModpointsModule.add("123456789", 5)
if newTotal then
    print("Added 5 points. New total:", newTotal)
    print("Added data:", data)
end

-- Add 1 modpoint (default)
local newTotal = ModpointsModule.add("123456789")
```

#### `ModpointsModule.set(discordUserId, amount)`
Sets the exact amount of modpoints for a Discord user.

**Parameters:**
- `discordUserId` (string) - The Discord user ID
- `amount` (number) - The exact amount to set

**Returns:**
- `newTotal` (number) - The new total modpoints
- `data` (table) - Full response data from the API

**Example:**
```lua
local newTotal, data = ModpointsModule.set("123456789", 10)
if newTotal then
    print("Set points to 10. Previous was:", data.previous)
end
```

#### `ModpointsModule.remove(discordUserId, amount)`
Removes modpoints from a Discord user's account.

**Parameters:**
- `discordUserId` (string) - The Discord user ID
- `amount` (number, optional) - Amount to remove (removes all if not specified)

**Returns:**
- `remaining` (number) - The remaining modpoints
- `data` (table) - Full response data from the API

**Example:**
```lua
-- Remove 3 modpoints
local remaining, data = ModpointsModule.remove("123456789", 3)
if remaining then
    print("Removed 3 points. Remaining:", remaining)
end

-- Remove all modpoints
local remaining = ModpointsModule.remove("123456789")
```

### Utility Functions

#### `ModpointsModule.health()`
Checks if the Apocrypha API is healthy and running.

**Returns:**
- `isHealthy` (boolean) - Whether the API is healthy
- `data` (table) - Health check response data

**Example:**
```lua
local isHealthy, data = ModpointsModule.health()
if isHealthy then
    print("API is healthy! Bot status:", data.botStatus)
    print("Bot PID:", data.botPid)
else
    print("API health check failed:", data)
end
```

#### `ModpointsModule.getAll()`
Retrieves comprehensive modpoints statistics.

**Returns:**
- `data` (table) - Statistics including totalUsers and totalPoints

**Example:**
```lua
local data = ModpointsModule.getAll()
if data then
    print("Total users:", data.totalUsers)
    print("Total points:", data.totalPoints)
    print("All user data:", data.data)
end
```

## Client-Server Communication

Since clients cannot make HTTP requests directly, you'll need to create a RemoteFunction to communicate between client and server.

### Server Setup Example

```lua
-- Server Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModpointsModule = require(ReplicatedStorage.ModpointsModule)

-- Create RemoteFunction for client-server communication
local ModpointsRemote = Instance.new("RemoteFunction")
ModpointsRemote.Name = "ModpointsRemote"
ModpointsRemote.Parent = ReplicatedStorage

-- Handle modpoints requests from client
ModpointsRemote.OnServerInvoke = function(player, action, userId, amount)
    if action == "check" then
        return ModpointsModule.check(userId)
    elseif action == "add" then
        return ModpointsModule.add(userId, amount)
    elseif action == "set" then
        return ModpointsModule.set(userId, amount)
    elseif action == "remove" then
        return ModpointsModule.remove(userId, amount)
    elseif action == "health" then
        return ModpointsModule.health()
    elseif action == "getAll" then
        return ModpointsModule.getAll()
    else
        return nil, "Invalid action"
    end
end
```

### Client Usage Example

```lua
-- Client Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModpointsRemote = ReplicatedStorage:WaitForChild("ModpointsRemote")

-- Check modpoints
local points, data = ModpointsRemote:InvokeServer("check", "123456789")
if points then
    print("User has", points, "modpoints")
end

-- Add modpoints
local newTotal = ModpointsRemote:InvokeServer("add", "123456789", 5)

-- Check API health
local isHealthy = ModpointsRemote:InvokeServer("health")
```

### Available Client Actions
- `"check"` - Check user modpoints
- `"add"` - Add modpoints
- `"set"` - Set exact modpoints
- `"remove"` - Remove modpoints
- `"health"` - Check API health
- `"getAll"` - Get all statistics

## Configuration

### API Endpoints
The module connects to the following Apocrypha API endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/health` | GET | Health check |
| `/api/modpoints` | GET | Get all modpoints |
| `/api/modpoints/:userId` | GET | Get user modpoints |
| `/api/modpoints/:userId` | POST | Add modpoints |
| `/api/modpoints/:userId` | PUT | Set modpoints |
| `/api/modpoints/:userId` | DELETE | Remove modpoints |

### Base URL
```
https://modmpointsapoc.vercel.app
```

## Examples

### Complete Integration Example

```lua
-- Server Script
local ModpointsModule = require(game.ReplicatedStorage.ModpointsModule)

-- Handle player joining
game.Players.PlayerAdded:Connect(function(player)
    if player.Name == "abcgdhalt" then
        -- Check their modpoints
        local points = ModpointsModule.check("123456789")
        if points then
            print(player.Name, "has", points, "modpoints")
        end
        
        -- Add welcome bonus
        ModpointsModule.add("123456789", 10)
    end
end)

-- Chat command system
game.Players.PlayerAdded:Connect(function(player)
    player.Chatted:Connect(function(message)
        if message:sub(1, 8) == "!points " then
            local userId = message:sub(9)
            local points = ModpointsModule.check(userId)
            if points then
                player:SendMessage("User has " .. points .. " modpoints")
            end
        end
    end)
end)
```

### Client-Side UI Example

```lua
-- Client Script
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ModpointsRemote = ReplicatedStorage:WaitForChild("ModpointsRemote")

-- Create UI to display modpoints
local function createModpointsUI()
    local screenGui = Instance.new("ScreenGui")
    local frame = Instance.new("Frame")
    local pointsLabel = Instance.new("TextLabel")
    
    -- UI setup code here...
    
    -- Update points display
    local function updatePoints()
        local points = ModpointsRemote:InvokeServer("check", "123456789")
        if points then
            pointsLabel.Text = "Modpoints: " .. points
        end
    end
    
    updatePoints()
end
```

## Error Handling

The module includes comprehensive error handling:

```lua
local points, error = ModpointsModule.check("123456789")
if not points then
    print("Error occurred:", error)
    -- Handle error appropriately
end
```

### Common Error Types
- **Network errors** - Connection issues
- **API errors** - Server-side problems
- **Invalid parameters** - Missing or incorrect data
- **JSON parsing errors** - Response format issues

## Testing

### Manual Testing
```lua
-- Test all functions
local testUserId = "123456789"

-- Health check
local isHealthy = ModpointsModule.health()
print("API Health:", isHealthy)

-- Check points
local points = ModpointsModule.check(testUserId)
print("Initial points:", points)

-- Add points
local newTotal = ModpointsModule.add(testUserId, 5)
print("After adding 5:", newTotal)

-- Remove points
local remaining = ModpointsModule.remove(testUserId, 2)
print("After removing 2:", remaining)
```

## Performance

- **HTTP requests** are optimized with proper error handling
- **Memory usage** is minimal with proper cleanup
- **Response times** depend on API latency (typically < 100ms)

## Security

- **Server-side validation** of all parameters
- **No sensitive data** exposed to clients
- **HTTP requests** only made from server
- **Input sanitization** for all user data
