// demi-16
// user interface
// Jacob Peck

UI := Object clone do(
  clone := method(self)
  
  rl := ReadLine
  c := CPU
  version := "April 2012"
  spec_version := "1.7 RFE"
  
  welcome := method(
    writeln("demi-16, version #{self version} (spec version: #{self spec_version})" interpolate)
  )
  
  initialize := method(
    c initialize
    self rl prompt = "demi-16> "
    self load_history
  )
  
  load_history := method(
    try(
      self rl loadHistory(".demi_history")
    )
  )
  
  save_history := method(
    try(
      self rl saveHistory(".demi_history")
    )
  )
  
  read_line := method(
    l := self rl readLine
    self rl addHistory(l)
    l
  )
  
  run := method(
    self initialize
    self welcome
    loop(
      in := self read_line
      if(in asLowercase == "quit", break)
      ex := try(c doString(in))
      if(ex != nil, writeln("incorrect command line"))
    )
    self save_history
  )
)
