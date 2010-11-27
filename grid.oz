functor
export
   newGrid:NewGrid
   getItemAt:GetItemAt
   setItemAt:SetItemAt

define
   
   fun {NewGrid X Y}
      {Array.new 0 X {Array.new 0 Y block( state:_ ports:nil)}}
   end

   fun {GetItemAt Arr X Y}
      {Array.get {Array.get Arr X} Y}
   end

   proc {SetItemAt Arr X Y NewItem}
      {Array.put {Array.get Arr X} Y NewItem}
   end
   
end
