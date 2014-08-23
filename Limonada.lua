
-- GLOBALES --------------------------------------------------------------

require("iuplua")
require("tools")
require("limonada-gui")
pr = require("proAudioRt")
vk = require("vk_codes")
keystate = tools.keystate

-- Funciones
main, calcular_clima, calcular_eventos, calcular_resultados,
x_TIM_timer, x_BUT_salir, x_BUT_ayuda, x_BUT_ayuda_ok,
x_BUT_1jug, x_BUT_2jug, jugar, pantalla_decisiones, x_BUT_decision_OK,
x_BUT_cambiar_vasos, x_BUT_cambiar_anuncios, x_BUT_cambiar_precio,
validar_vasos, validar_anuncios, x_BUT_informe_OK, game_over,
pantalla_informe = nil

-- Gadgets
TIM_timer = nil

-- Sonidos
if (not pr.create()) then
  iup.Alarm("", "Error al inicializar proAudioRt.", "OK")
  os.exit()
end
snd_exito = pr.sampleFromFile("snd/exito.ogg")
snd_fracaso = pr.sampleFromFile("snd/fracaso.ogg")
snd_gallo = pr.sampleFromFile("snd/gallo.ogg")
snd_impuesto = pr.sampleFromFile("snd/impuesto.ogg")

-- Variables
	CAPITAL_INICIAL = 1000  -- 10 euros
	IMPUESTO_INICIAL = 1000
	IMPUESTO_SUBIDA = 200
	PRECIO_ANUNCIO = 15
	T_CALUROSO = 1
	T_DESPEJADO = 2
	T_NUBLADO = 3
	T_TORMENTA = 4
		
	sonido_onoff = 0
	num_jugadores = 0
	jug_actual = 0
	dia = 0
	capital = {0, 0}
	coste_por_vaso = 0
	vasos_preparados = {0, 0}
	vasos_vendidos = {0, 0}
	vasos_pvp = {0, 0}
	anuncios = {0, 0}
	impuesto = 0
	clima = 0
	factor_clima = 0
	obras = 0
	obreros_sedientos = 0
	tormenta_fatal = 0

-- FIN GLOBALES ----------------------------------------------------------

function main()
  Crear_GUI()
  TIM_timer = iup.timer{}
  iup.SetAttributes(TIM_timer, "TIME=200, RUN=YES")
  TIM_timer.action_cb = function() x_TIM_timer() end
  iup.ShowXY(DLG_menu, iup.CENTER, iup.CENTER)
  iup.MainLoop()
end

--------------------------------------------------------------------------
-- jugar()                                                              --
--------------------------------------------------------------------------

function jugar()
  if (num_jugadores == 1) then
    iup.Alarm("Limonada", "Va a comenzar el juego con un jugador " ..
              "¡A ver los días que aguantas!", "OK")
  else
    iup.Alarm("Limonada", "Va a comenzar el juego con " .. num_jugadores ..
              " jugadores. ¡Ganará el último en arruinarse!", "OK")
  end
  for i = 1, num_jugadores do
    capital[i] = CAPITAL_INICIAL
  end
  jug_actual = 1
  dia = 0
  impuesto = IMPUESTO_INICIAL
  for i = 1, 2 do
    vasos_preparados[i] = 0
    vasos_vendidos[i] = 0
    vasos_pvp[i] = 0
    anuncios[i] = 0
  end
  -- Comenzar el juego
  pantalla_decisiones()
end

--------------------------------------------------------------------------
-- calcular_clima()                                                     --
--------------------------------------------------------------------------

function calcular_clima()
  local r, info, prob_lluvia
  
  r = math.random(0, 9)
  if (r <= 2 ) then    clima = T_CALUROSO
  elseif (r <= 6) then clima = T_DESPEJADO
  elseif (r <= 8) then clima = T_NUBLADO
  else                 clima = T_TORMENTA 
  end
  
  prob_lluvia = 0
  if (clima == T_NUBLADO) then
    prob_lluvia = 30 + math.random(0, 6) * 10   -- 30% a 90%
    factor_clima = 1.0 - (prob_lluvia / 100)
  elseif (clima == T_TORMENTA) then
    prob_lluvia = 100
    factor_clima = 0.05
  elseif (clima == T_CALUROSO) then
    factor_clima = 2.0
  else
    factor_clima = 1.0
  end
  
  if (clima == T_DESPEJADO) then 
    info = "Despejado"
    iup.SetAttribute(LBL_banner, "IMAGE", "img_t_despejado")
  elseif (clima == T_NUBLADO) then
    info = "Nublado\nHay una probabilidad de lluvia ligera del " ..
            prob_lluvia .. "% y el tiempo es fresquito."
    iup.SetAttribute(LBL_banner, "IMAGE", "img_t_nublado")
  elseif (clima == T_CALUROSO) then
    info = "Mucho calor\n¡Se prevé un calor achicharrante!"
    iup.SetAttribute(LBL_banner, "IMAGE", "img_t_caluroso")
  elseif (clima == T_TORMENTA) then
    info = "Chubascos y tormentas\nUna gran tormenta se ha desatado esta mañana."
    iup.SetAttribute(LBL_banner, "IMAGE", "img_t_tormenta")
  end
  return info
end

--------------------------------------------------------------------------
-- calcular_eventos()                                                   --
--------------------------------------------------------------------------

function calcular_eventos()
  local evento
  
  evento = ""
  tormenta_fatal = false
  obreros_sedientos = false
  obras = false
  if (clima == T_TORMENTA) then
    if (math.random(0, 99) < 50) then
      tormenta_fatal = true
    end
  else
    if (math.random(0, 99) < 25) then
      evento = "Obras en la calle, tráfico cortado."
      obras = true
      if (math.random(0, 99) < 25) then 
        obreros_sedientos = true
      end
    end
  end
  return evento
end  
    
--------------------------------------------------------------------------
-- pantalla_decisiones()                                                --
--------------------------------------------------------------------------

function pantalla_decisiones()
  local explicacion = ""
  local euro, cent
  
  -- Mostrar ventana decisiones
  iup.ShowXY(DLG_decisiones, iup.CENTER, iup.CENTER)
  iup.Hide(DLG_menu)
  iup.Hide(DLG_informe)
  
  pr.soundPlay(snd_gallo)   -- canto del gallo
  -- Sucesos al pasar los días
  if (jug_actual == 1) then
    dia = dia + 1
    -- subidas de precios
    if (dia < 3) then
      coste_por_vaso = 2
    elseif (dia < 7) then
      coste_por_vaso = 4
      if (dia == 3) then 
        explicacion = "(ha subido el precio del azúcar)" end
    else
      coste_por_vaso = 5
      if (dia == 7) then 
        explicacion = "(ha subido el precio de los limones)" end
    end
    -- subidas de impuesto
    if ((dia == 5) or (dia == 8) or (dia >= 10)) then
      impuesto = impuesto + IMPUESTO_SUBIDA
      pr.soundPlay(snd_impuesto)
      euro, cent = math.modf(impuesto / 100)
      cent = cent * 100
      iup.Alarm("Aviso", "Sube el impuesto municipal.\n" .. 
                "Tasa actual: " .. euro .. "." .. cent, "OK")
    end
  end
  
  -- Mostrar información y opciones
  -- calcular_clima() también ajusta gráfico de banner
  if (jug_actual == 1) then
    iup.SetAttribute(LBL_clima, "TITLE",
      calcular_clima() .. "\n" .. calcular_eventos())
  end
  iup.SetAttribute(LBL_dia, "TITLE", " DÍA " .. dia)
  iup.SetAttribute(LBL_jug, "TITLE", " JUG. " .. jug_actual)
  iup.SetAttribute(LBL_coste, "TITLE", " El coste por limonada es de " ..
    coste_por_vaso .. " céntimos.\n" .. explicacion)
    
  euro, cent = math.modf(capital[jug_actual] / 100)
  cent = cent * 100
  iup.SetAttribute(LBL_capital, "TITLE", " El capital actual es de " ..
    euro .. "." .. cent .. " euros.")
  iup.SetAttribute(LBL_vasos, "TITLE", vasos_preparados[jug_actual])
  iup.SetAttribute(LBL_cuantos_anuncios, "TITLE", " Anuncios (a " ..
    PRECIO_ANUNCIO .. " cent.):")
  iup.SetAttribute(LBL_precio, "TITLE", vasos_pvp[jug_actual] .. " cent.")
end

---------------------------------------------------------------------------
-- pantalla_informe()                                                     -
---------------------------------------------------------------------------

function pantalla_informe()
  local ingresos, gastos_limonada, gastos_publi, beneficios
  local euro, cent
  local set = iup.SetAttribute
  
  -- Mostrar ventana informe
  iup.ShowXY(DLG_informe, iup.CENTER, iup.CENTER)
  iup.Hide(DLG_decisiones)
  
  -- Mostrar información
  set(LBL_dia_inf, "TITLE", " DÍA " .. dia)
  set(LBL_jug_inf, "TITLE", " JUG. " .. jug_actual)
  set(LBL_txtvendido, "TITLE", " Vasos vendidos (a " .. 
      vasos_pvp[jug_actual] .. " cent.):")
  set(LBL_vendido, "TITLE", vasos_vendidos[jug_actual])
  set(LBL_txtingresos, "TITLE", " INGRESOS POR VENTAS:")
  ingresos = vasos_vendidos[jug_actual] * vasos_pvp[jug_actual]
  euro, cent = math.modf(ingresos / 100)
  cent = cent * 100
  set(LBL_ingresos, "TITLE", euro .. "." .. cent .. "€")
  set(LBL_txtpreparado, "TITLE", " Vasos preparados (a " ..
      coste_por_vaso .. " cent.):")
  set(LBL_preparado, "TITLE", vasos_preparados[jug_actual])
  set(LBL_txtgastos, "TITLE", " GASTOS EN LIMONADA: ")
  gastos_limonada = vasos_preparados[jug_actual] * coste_por_vaso
  euro, cent = math.modf(gastos_limonada / 100)
  cent = cent * 100
  set(LBL_gastos, "TITLE", euro .. "." .. cent .. "€")
  set(LBL_txtanuncios, "TITLE", " Anuncios puestos (a " .. 
      PRECIO_ANUNCIO .. " cent.):")
  set(LBL_anuncios, "TITLE", anuncios[jug_actual])
  set(LBL_txtpubli, "TITLE", " GASTOS EN PUBLICIDAD: ")
  gastos_publi = anuncios[jug_actual] * PRECIO_ANUNCIO
  euro, cent = math.modf(gastos_publi / 100)
  cent = cent * 100
  set(LBL_publi, "TITLE", euro .. "." .. cent .. "€")
  set(LBL_txtimpuesto, "TITLE", " IMPUESTO MUNICIPAL: ")
  euro, cent = math.modf(impuesto / 100)
  cent = cent * 100
  set(LBL_impuesto, "TITLE", euro .. "." .. cent .. "€")
  set(LBL_impuesto, "FGCOLOR", "255 255 0")
  set(LBL_txtbeneficios, "TITLE", " BENEFICIOS:")
  beneficios = ingresos - gastos_limonada - gastos_publi - impuesto
  if (beneficios >= 0) then 
    euro, cent = math.modf(beneficios / 100)
    cent = cent * 100
    set(LBL_beneficios, "TITLE", euro .. "." .. cent .. "€")
    set(LBL_beneficios, "FGCOLOR", "0 255 0")
  else
    euro, cent = math.modf(-beneficios / 100)
    cent = cent * 100
    set(LBL_beneficios, "TITLE", "-" .. euro .. "." .. cent .. "€")
    set(LBL_beneficios, "FGCOLOR", "255 0 0")
  end
  set(LBL_txtcapitalact, "TITLE", " CAPITAL ACTUAL:")
  if (capital[jug_actual] >= 0) then 
    euro, cent = math.modf(capital[jug_actual] / 100)
    cent = cent * 100
    set(LBL_capitalact, "TITLE", euro .. "." .. cent .. "€")
    set(LBL_capitalact, "FGCOLOR", "0 255 0")
  else
    euro, cent = math.modf(-capital[jug_actual] / 100)
    cent = cent * 100
    set(LBL_capitalact, "TITLE", "-" .. euro .. "." .. cent .. "€")
    set(LBL_capitalact, "FGCOLOR", "255 0 0")
  end
end

---------------------------------------------------------------------------
-- calcular_resultados()                                                  -
---------------------------------------------------------------------------

function calcular_resultados()
  local n1, n2, pvp
  local beneficio_publi, ingresos, gastos
  local clientes = 500    -- personas que pasan por la calle
  
  -- Calcular cuantos vasos se han vendido
  if (obras == true) then clientes = math.floor(clientes / 2) end
  n1 = math.floor(clientes / 5) -- en el mejor caso 1 de cada 5 personas
  pvp = vasos_pvp[jug_actual]
  if (pvp >= 20)  then n1 = math.floor(n1 / 2) end
  if (pvp >= 50)  then n1 = math.floor(n1 / 2) end
  if (pvp >= 100) then n1 = math.floor(n1 / 2) end
  if (pvp >= 150) then n1 = math.floor(n1 / 2) end
  if (pvp >= 200) then n1 = 0 end
  
  -- Calcular incremento de ventas por anuncios
  beneficio_publi = anuncios[jug_actual] / 100
  if (beneficio_publi > 1.0) then beneficio_publi = 1.0 end
  
  -- Añadir influencia del clima
  n2 = math.floor(factor_clima * n1 * (1 + beneficio_publi))
  if (tormenta_fatal == true) then
    pr.soundPlay(snd_fracaso)
    iup.Message("Imprevisto", "Una terrible tormenta estropea toda la limonada.")
    n2 = 0
  elseif (obreros_sedientos == true) then 
    pr.soundPlay(snd_exito)
    iup.Message("Imprevisto", "Los obreros sedientos compran toda la limonada.")
    n2 = vasos_preparados[jug_actual]
  end
  vasos_vendidos[jug_actual] = math.min(n2, vasos_preparados[jug_actual])
  
  -- Calcular ingresos y gastos
  gastos = vasos_preparados[jug_actual] * coste_por_vaso +
            anuncios[jug_actual] * PRECIO_ANUNCIO + impuesto
  ingresos = vasos_vendidos[jug_actual] * vasos_pvp[jug_actual]
  
  -- Calcular capital
  capital[jug_actual] = capital[jug_actual] + ingresos - gastos
  
  -- Sonido acorde con los resultados
  if (ingresos > gastos) then
    pr.soundPlay(snd_exito)
  else
    pr.soundPlay(snd_fracaso)
  end
end 

---------------------------------------------------------------------------
-- validar_vasos()                                                        -
---------------------------------------------------------------------------

function validar_vasos()
  local v, a, maximo
  
  v = vasos_preparados[jug_actual]
  a = anuncios[jug_actual]
  if (v * coste_por_vaso + a * PRECIO_ANUNCIO > capital[jug_actual]) then
    maximo = math.floor((capital[jug_actual] - a * PRECIO_ANUNCIO) / coste_por_vaso)
    iup.Message("Limonada", "Tu capital solo alcanza para "..maximo.." vasos.")
    vasos_preparados[jug_actual] = maximo
    iup.SetAttribute(LBL_vasos, "TITLE", maximo)
  end
end
  
---------------------------------------------------------------------------
-- validar_anuncios()                                                     -
---------------------------------------------------------------------------

function validar_anuncios()
  local v, a, maximo
  
  v = vasos_preparados[jug_actual]
  a = anuncios[jug_actual]
  if (v * coste_por_vaso + a * PRECIO_ANUNCIO > capital[jug_actual]) then
    maximo = math.floor((capital[jug_actual] - v * coste_por_vaso) / PRECIO_ANUNCIO)
    iup.Message("Limonada", "Tu capital solo alcanza para "..maximo.." anuncios.")
    anuncios[jug_actual] = maximo
    iup.SetAttribute(LBL_anuncios, "TITLE", maximo)
  end
end
  
---------------------------------------------------------------------------
-- game_over()                                                            -
---------------------------------------------------------------------------

function game_over(jugador)
  if (num_jugadores == 1) then
    iup.Message("Limonada", "GAME OVER\nHas resistido "..dia.." días")
  else
    iup.Message("Limonada", "GAME OVER\nHa ganado el jugador "..(3-jugador))
  end
  iup.ShowXY(DLG_menu, iup.CENTER, iup.CENTER)
  iup.Hide(DLG_informe)
end

---------------------------------------------------------------------------
-- Callbacks                                                              -
---------------------------------------------------------------------------

function x_TIM_timer()
  local state = keystate(vk["esc"])
  if ((state < 0) or (state == 1)) then
    iup.ShowXY(DLG_menu, iup.CENTER, iup.CENTER)
    iup.Hide(DLG_decisiones)
    iup.Hide(DLG_informe)
  end
end

--------------------------------------------------------------------------

function x_BUT_salir()
  if (iup.Alarm("Salir de Limonada", "¿Seguro?", "Sí", "No") == 2) then
    return
  end
  pr.soundStop()
  pr.sampleDestroy(snd_exito)
  pr.sampleDestroy(snd_fracaso)
  pr.sampleDestroy(snd_gallo)
  pr.sampleDestroy(snd_impuesto)
  pr.destroy()
  iup.ExitLoop()
end

--------------------------------------------------------------------------

function x_BUT_ayuda()
  iup.ShowXY(DLG_ayuda, iup.CENTER, iup.CENTER)
  iup.Hide(DLG_menu)
end
  
--------------------------------------------------------------------------

function x_BUT_ayuda_ok()
  iup.ShowXY(DLG_menu, iup.CENTER, iup.CENTER)
  iup.Hide(DLG_ayuda)
end

--------------------------------------------------------------------------

function x_BUT_1jug()
  num_jugadores = 1
  jugar()
end

--------------------------------------------------------------------------

function x_BUT_2jug()
  num_jugadores = 2
  jugar()
end

--------------------------------------------------------------------------

function x_BUT_cambiar_vasos()
  local res, num
  
  res, num = iup.GetParam("¿Cuantos vasos?", nil,
    "Vasos: %i[0,100]\n", vasos_preparados[jug_actual])
  if (num == nil) then num = 0 end
  vasos_preparados[jug_actual] = num
  iup.SetAttribute(LBL_vasos, "TITLE", num)
  validar_vasos()
end

--------------------------------------------------------------------------

function x_BUT_cambiar_anuncios()
  local res, num
  
  res, num = iup.GetParam("¿Cuantos anuncios?", nil,
    "Anuncios: %i[0,100]\n", anuncios[jug_actual])
  if (num == nil) then num = 0 end
  anuncios[jug_actual] = num
  iup.SetAttribute(LBL_anuncios, "TITLE", num)
  validar_anuncios()
end

--------------------------------------------------------------------------

function x_BUT_cambiar_precio()
  local res, num
  
  res, num = iup.GetParam("Precio por vaso (céntimos):", nil,
    "Precio (cent.): %i[0,300]\n", vasos_pvp[jug_actual])
  if (num == nil) then num = 0 end
  vasos_pvp[jug_actual] = num
  iup.SetAttribute(LBL_precio, "TITLE", num)
end

--------------------------------------------------------------------------

function x_BUT_decision_OK()
  jug_actual = jug_actual + 1
  if (jug_actual > num_jugadores) then 
    jug_actual = 1
    calcular_resultados()
    pantalla_informe()
  else
    pantalla_decisiones()
  end
end

--------------------------------------------------------------------------

function x_BUT_informe_OK()
  if (capital[jug_actual] < 0) then 
    game_over(jug_actual)
  else
    jug_actual = jug_actual + 1
    if (jug_actual > num_jugadores) then 
      jug_actual = 1
      pantalla_decisiones()
    else
      calcular_resultados()
      pantalla_informe()
    end
  end
end

--------------------------------------------------------------------------

main()
