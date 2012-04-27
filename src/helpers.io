// demi-16
// helpers
// Jacob Peck

twosCompliment := method(value,
  orig := value asBinary
  while(orig size < 16, orig prependSeq("0"))
  new := ""
  toggle := false
  for(i, orig size - 1, 0, -1,
    //writeln("#{i} #{orig at(i)}" interpolate)
    if(toggle,
      if(orig at(i) == "1" at(0),
        new = "0" .. new
        ,
        new = "1" .. new
      )
      ,
      if(orig at(i) == "0" at(0),
        new = "0" .. new
        ,
        new = "1" .. new
        toggle = true
      )
    )
  )
  //writeln(new)
  new fromBase(2)
)

pad := method(val,
  v := val toBase(16)
  while(v size < 4, v prependSeq("0"))
  v
)
