MACHINE Ticket

VARIABLES
    serve, next, limitv, record

INVARIANT         
    serve : NATURAL & next : NATURAL & limitv : NATURAL & record : NATURAL
        & serve <= next & next <= limitv

INITIALISATION    
    serve, next, record, limitv := 0,0, 0, 500

OPERATIONS

ss <-- serve_next =
    PRE serve < next
    THEN ss, serve, record := serve + 1, serve + 1, 0
    END;

tt <-- take_ticket =
   PRE next + 1<= limitv
   THEN tt, next, record := next, next+1, record+1
   END;

limit(nn)=
   PRE nn : NATURAL & nn >= next
   THEN limitv := nn
   END;

tt <-- query = 
   tt := next - serve;

tt <-- query_record = 
   tt := record;

reset =
  serve, next, record, limitv := 0,0, 0, 500;

undo_serve = 
   PRE serve - 1 >= 0
   THEN serve := serve - 1
   END

END

