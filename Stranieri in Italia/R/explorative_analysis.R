# Apolidi nelle provincie italiane

df |> 
  filter(iso == "999",
         time == 2022,
         sesso == "totale",
         value >10,
         str_detect(itter107, "ITC[:digit:]{2}")
  )
