functor
export
   newGrid:NewGrid
   getItemAt:GetItemAt

define
   
   fun {NewGrid X Y}
      {Array.new 0 X {Array.new 0 Y block( state:_ ports:nil)}}
   end

   fun {GetItemAt Arr X Y}
      {Array.get {Array.get Arr X} Y}
   end

   
end
