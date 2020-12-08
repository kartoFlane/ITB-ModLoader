local testsuite = Tests.Testsuite()

function testsuite.test_vector2_xy()
	local v = math.vec2(11,22)

	Assert.TableEquals({11,22}, v, "math.vec2(x, y)")
	
	return true
end

function testsuite.test_vector2_v2()
	local v2 = math.vec2(11,22)
	local v = math.vec2(v2)

	Assert.TableEquals({11,22}, v, "math.vec2(vec2)")
	
	return true
end

function testsuite.test_vector3_xyz()
	local v = math.vec3(111,222,333)

	Assert.TableEquals({111,222,333}, v, "math.vec3(x, y, z)")
	
	return true
end

function testsuite.test_vector3_v3()
	local v3 = math.vec3(111,222,333)
	local v = math.vec3(v3)

	Assert.TableEquals({111,222,333}, v, "math.vec3(vec3)")
	
	return true
end

function testsuite.test_vector3_v2z()
	local v2 = math.vec2(11,22)
	local v = math.vec3(v2,333)

	Assert.TableEquals({11,22,333}, v, "math.vec3(vec2, z)")
	
	return true
end

function testsuite.test_vector3_xv2()
	local v2 = math.vec2(11,22)
	local v = math.vec3(111,v2)

	Assert.TableEquals({111,11,22}, v, "math.vec3(x, vec2)")
	
	return true
end

function testsuite.test_vector4_xywh()
	local v = math.vec4(1111,2222,3333,4444)

	Assert.TableEquals({1111,2222,3333,4444}, v, "math.vec4(x, y, w, h)")
	
	return true
end

function testsuite.test_vector4_v4()
	local v4 = math.vec4(1111,2222,3333,4444)
	local v = math.vec4(v4)

	Assert.TableEquals({1111,2222,3333,4444}, v, "math.vec4(vec4)")
	
	return true
end

function testsuite.test_vector4_v3h()
	local v3 = math.vec3(111,222,333)
	local v = math.vec4(v3,4444)

	Assert.TableEquals({111,222,333,4444}, v, "math.vec4(vec3, h)")
	
	return true
end

function testsuite.test_vector4_xv3()
	local v3 = math.vec3(111,222,333)
	local v = math.vec4(1111,v3)

	Assert.TableEquals({1111,111,222,333}, v, "math.vec4(x, vec3)")
	
	return true
end

function testsuite.test_vector4_v2wh()
	local v2 = math.vec2(11,22)
	local v = math.vec4(v2,3333,4444)

	Assert.TableEquals({11,22,3333,4444}, v, "math.vec4(vec2, w, h)")
	
	return true
end

function testsuite.test_vector4_xv2h()
	local v2 = math.vec2(11,22)
	local v = math.vec4(1111,v2,4444)

	Assert.TableEquals({1111,11,22,4444}, v, "math.vec4(x, vec2, h)")
	
	return true
end

function testsuite.test_vector4_xyv2()
	local v2 = math.vec2(11,22)
	local v = math.vec4(1111,2222,v2)

	Assert.TableEquals({1111,2222,11,22}, v, "math.vec4(x, y, vec2)")
	
	return true
end

function testsuite.test_vector4_v2v2()
	local v2 = math.vec2(11,22)
	local v = math.vec4(v2,v2)

	Assert.TableEquals({11,22,11,22}, v, "math.vec4(vec2, vec2)")
	
	return true
end

function testsuite.test_vector2_add()
	local a = math.vec2(1,2)
	local b = math.vec2(3,4)

	Assert.TableEquals({4,6}, a + b, "math.vec2().__add")
	
	return true
end

function testsuite.test_vector3_add()
	local a = math.vec3(1,2,3)
	local b = math.vec3(4,5,6)

	Assert.TableEquals({5,7,9}, a + b, "math.vec3().__add")
	
	return true
end

function testsuite.test_vector4_add()
	local a = math.vec4(1,2,3,4)
	local b = math.vec4(5,6,7,8)

	Assert.TableEquals({6,8,10,12}, a + b, "math.vec4().__add")
	
	return true
end

function testsuite.test_vector2_sub()
	local a = math.vec2(5,5)
	local b = math.vec2(1,2)

	Assert.TableEquals({4,3}, a - b, "math.vec2().__sub")
	
	return true
end

function testsuite.test_vector3_sub()
	local a = math.vec3(5,5,5)
	local b = math.vec3(1,2,3)

	Assert.TableEquals({4,3,2}, a - b, "math.vec3().__sub")
	
	return true
end

function testsuite.test_vector4_sub()
	local a = math.vec4(5,5,5,5)
	local b = math.vec4(1,2,3,4)

	Assert.TableEquals({4,3,2,1}, a - b, "math.vec4().__sub")
	
	return true
end

function testsuite.test_vector2_dot()
	local a = math.vec2(1,2)
	local b = math.vec2(3,4)

	Assert.Equals(1 * 3 + 2 * 4, a * b, "math.vec2().__mul")
	
	return true
end

function testsuite.test_vector3_dot()
	local a = math.vec3(1,2,3)
	local b = math.vec3(4,5,6)

	Assert.Equals(1*4 + 2*5 + 3*6, a * b, "math.vec3().__mul")
	
	return true
end

function testsuite.test_vector4_dot()
	local a = math.vec4(1,2,3,4)
	local b = math.vec4(5,6,7,8)

	Assert.Equals(1*5 + 2*6 + 3*7 + 4*8, a * b, "math.vec4().__mul")
	
	return true
end

function testsuite.test_vector2_cross()
	local a = math.vec2(1,2)
	local b = math.vec2(3,4)

	Assert.Equals(1*4 - 2*3, a:cross(b), "math.vec2().cross")
	
	return true
end

function testsuite.test_vector3_cross()
	local a = math.vec3(1,2,3)
	local b = math.vec3(4,5,6)

	Assert.TableEquals({
		2*6 - 3*5,
		3*4 - 1*6,
		1*5 - 2*4
	}, a:cross(b), "math.vec3().cross")
	
	return true
end

return testsuite