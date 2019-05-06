Sorry to interject without context ... but this also introduces
dependency on the actual hardware; BIG-ENDIAN and LITTLE-ENDIAN
machines may give a different ordering of bits/bytes unless you define
a preferred endian-ness in Q and explicitly take care of it during
conversions.

- Atul


On 07/10/17 8:37 am, Ramesh Subramonian wrote:

A very dangerous operator but I’ve provided it in any case. Look at
TESTS/test_cast.lua.

@Utpal:You can use it to create a random B1 vector as follows. Say you create

x = Q.rand( { lb = 100, ub = 200, qtype = “I8", len = 3 } )

Then x has 3 elements.

If you do

y = Q.cast(x, “B1”) then

y has 3*64 = 192 elements.

Note that x and y point to the same vector and that the vector will
now be interpreted as B1 instead of I8.

There are places where this is useful but it is a very dangerous
one. What is happening is that we are interpreting bits created in one
way in a completely different way.

Ramesh

