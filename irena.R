(roster
   %>% transmute(Class=Class
      , ID = sub("#", "", idnum)
      , mark=courseGrade
   ) %>% filter(!is.na(ID))
) %>% readr::write_csv(col_names=FALSE)

