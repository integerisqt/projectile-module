local projectile = {};


local function computeLaunchAngle(horizontalDistance, distanceY, initialSpeed, gravity)
    local distanceTimesGravity = horizontalDistance * gravity;
    local initialSpeedSquared = initialSpeed * initialSpeed;

    local inRoot = initialSpeedSquared * initialSpeedSquared - (gravity * ((distanceTimesGravity * horizontalDistance) + (2 * distanceY * initialSpeedSquared)));
    if inRoot <= 0 then
        return false, math.pi / 4;
    end

    local root = inRoot ^ 0.5;
    local inAtan1 = (initialSpeedSquared - root) / distanceTimesGravity;
    local inAtan2 = (initialSpeedSquared + root) / distanceTimesGravity;
    local answerAngle1 = math.atan(inAtan1);
    local answerAngle2 = math.atan(inAtan2);

    if answerAngle1 < answerAngle2 then
        return true, answerAngle1;
    else
        return true, answerAngle2;
    end
end

function projectile.computeLaunchVelocity(distanceVector, initalSpeed, gravity, allowOutOfRange)
    local horinzalDistanceVector = Vector3.new(distanceVector.X, 0, distanceVector.Z);
    local horizonalDistance = horinzalDistanceVector.Magnitude;

    local isInRange, launchAngle = computeLaunchAngle(horizonalDistance, distanceVector.Y, initalSpeed, gravity);
    if not isInRange and not allowOutOfRange then return; end

    local horizontalDirectionUnit = horinzalDistanceVector.Unit;
    local vy = math.sin(launchAngle);
    local xz = math.cos(launchAngle);
    local vx = horizontalDirectionUnit.X * xz;
    local vz = horizontalDirectionUnit.Z * xz;

    return Vector3.new(vx * initalSpeed, vy * initalSpeed, vz * initalSpeed);
end

function projectile.computeLaunchVelocityBeam(distanceVector, initalSpeed, gravity, allowOutOfRange)
    local distanceY = distanceVector.Y;
    local horizontalDistanceVector = Vector3.new(distanceVector.X, 0, distanceVector.Z);
    local horizontalDistance = horizontalDistanceVector.Magnitude;

    local isInRange, launchAngle = computeLaunchAngle(horizontalDistance, distanceY, initalSpeed, gravity);
    if not isInRange and not allowOutOfRange then return; end

    local horizontaldirectionUnit = horizontalDistanceVector.Unit;
	local vy = math.sin(launchAngle);
	local xz = math.cos(launchAngle);
	local vx = horizontaldirectionUnit.X * xz;
	local vz = horizontaldirectionUnit.Z * xz;

    local v0sin = vy * initalSpeed;
    local horizontalRangeHalf = ((initalSpeed * initalSpeed) / gravity * (math.sin(2 * launchAngle))) * 0.5;

    local flightTime;
    if horizontalRangeHalf <= horizontalDistance then
        flightTime = ((v0sin+(math.sqrt(v0sin^2+(2*-gravity*((distanceY))))))/gravity);
    else
        flightTime = ((v0sin-(math.sqrt(v0sin^2+(2*-gravity*((distanceY))))))/gravity);
    end
    return Vector3.new(vx * initalSpeed, vy * initalSpeed, vz * initalSpeed), flightTime;
end

function projectile.beamProjectile(g, v0, x0, t)
    local c = 0.125;
    local p3 = 0.5*g*t*t + v0*t + x0;
	local p2 = p3 - (g*t*t + v0*t)/3;
	local p1 = (c*g*t*t + 0.5*v0*t + x0 - c*(x0+p3))/(3*c) - p2;

    local curve0 = (p1 - x0).Magnitude;
	local curve1 = (p2 - p3).Magnitude;

	local b = (x0 - p3).Unit;
	local r1 = (p1 - x0).Unit;
	local u1 = r1:Cross(b).Unit;
	local r2 = (p2 - p3).Unit;
	local u2 = r2:Cross(b).Unit;
	b = u1:Cross(r1).Unit;

    local cfA = CFrame.fromMatrix(x0, r1, u1, b);
	local cfB = CFrame.fromMatrix(p3, r2, u2, b);

    return curve0, -curve1, cfA, cfB;
end

return projectile;
