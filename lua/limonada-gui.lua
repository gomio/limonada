
-- GLOBALES -----------

Crear_GUI, posrel = nil

-- Ventana inicial
DLG_menu, DLG_ayuda, DLG_decisiones, DLG_informe = nil
BUT_1jug, BUT_2jug, BUT_ayuda, BUT_salir = nil
CHK_sonido = nil
LBL_version = nil
EDT_ayuda = nil
BUT_ayuda_ok = nil
-- Ventana decisiones
LBL_banner, LBL_banner2 = nil
LBL_dia, LBL_jug, LBL_dia_inf, LBL_jug_inf = nil
LBL_titulo_clima, LBL_clima = nil
LBL_titulo_dia, LBL_coste, LBL_capital = nil
LBL_cuantos_vasos, LBL_cuantos_anuncios, LBL_que_precio = nil
LBL_vasos, LBL_anuncios, LBL_precio = nil
BUT_cambiar_vasos, BUT_cambiar_anuncios, BUT_cambiar_precio = nil
BUT_decision_OK = nil
-- Ventana informe
LBL_txtvendido, LBL_vendido, LBL_txtpreparado, LBL_preparado = nil
LBL_txtingresos, LBL_ingresos, LBL_txtgastos, LBL_gastos = nil
LBL_txtanuncios, LBL_anuncios, LBL_txtpubli, LBL_publi = nil
LBL_txtbeneficios, LBL_beneficios, LBL_txtcapitalact, LBL_capitalact = nil
LBL_txtimpuesto, LBL_impuesto = nil
BUT_informe_OK = nil

-- FIN GLOBALES -------

function Crear_GUI()
  local set = iup.SetAttributes
  local wx, wy = 360, 570   -- tamaño de ventana (área cliente)
  local tambarra = 30       -- tamaño de barra superior
  local inst
  
  iup.Load("img.led")       -- cargar gráficos
  
  -- Ventana menú principal ----------------------------------------------
  
  BUT_1jug = set(iup.button{}, posrel(wx, wy, 30, 60, 40, 5) ..
    ", TITLE=\"Un jugador\"")
  BUT_1jug.action = function(self) x_BUT_1jug() end  
  
  BUT_2jug = set(iup.button{}, posrel(wx, wy, 30, 67, 40, 5) ..
    ", TITLE=\"Dos jugadores\"")
  BUT_2jug.action = function(self) x_BUT_2jug() end  
  
  BUT_ayuda = set(iup.button{}, posrel(wx, wy, 30, 74, 40, 5) ..
    ", TITLE=\"Ayuda\"")
  BUT_ayuda.action = function(self) x_BUT_ayuda() end  
  
  BUT_salir = set(iup.button{}, posrel(wx, wy, 30, 81, 40, 5) ..
    ", TITLE=\"Salir\"")
  BUT_salir.action = function(self) x_BUT_salir() end  
  
  DLG_menu = iup.dialog {
    iup.vbox{
      BUT_1jug, BUT_2jug, BUT_ayuda, BUT_salir
    }
  }
  set(DLG_menu, "TITLE=Limonada, BACKGROUND=img_limonada, " ..
    "RASTERSIZE=" .. wx .. "x" ..(wy + tambarra).. ", MENUBOX=NO")
    
  -- Ventana Ayuda -------------------------------------------------------
  
  inst = 
  "Estás a cargo de un puesto de limonadas, y debes tomar estas " ..
	"decisiones cada día:\n" ..
	"1) Cuantos vasos de limonada preparar (se preparan todos al empezar el día)\n" ..
	"2) Cuantos anuncios poner (cada uno cuesta 15 céntimos)\n" ..
	"3) Cuanto cobrar por cada vaso.\n\n" ..
	"Comienzas con 10 euros de capital, y el coste de hacer cada vaso de " ..
	"limonada es de 2 céntimos (puede cambiar más adelante).\n" ..
	"Tus gastos son la suma del coste de las limonadas y el coste de los anuncios.\n\n" ..
	"Tus beneficios son la diferencia entre los ingresos por las ventas y los gastos.\n\n" ..
	"El número de vasos que vendes cada día depende del precio que cobras, " ..
	"del clima, del número de anuncios que pones y de otras cosas.\n\n" ..
	"Además, cada día hay que pagar un impuesto municipal (otro gasto más).\n\n" ..
	"Presta atención a tu capital, porque no puedes gastar más dinero del que tienes." ..
	"El juego termina cuando te quedas en números rojos. ¡SUERTE!"

  EDT_ayuda = set(iup.text{}, posrel(wx, wy, 5, 5, 88, 70) ..
    ", MULTILINE=YES, WORDWRAP=YES")
  iup.SetAttribute(EDT_ayuda, "VALUE", inst)
    
  BUT_ayuda_ok = set(iup.button{title = "OK"},
    posrel(wx, wy, 40, 80, 20, 10))
  BUT_ayuda_ok.action = function(self) x_BUT_ayuda_ok() end
    
  DLG_ayuda = iup.dialog{
    iup.vbox{
      EDT_ayuda, BUT_ayuda_ok
    }
  }
  set(DLG_ayuda, "TITLE=Ayuda, BACKGROUND=img_limonada, " ..
    "RASTERSIZE=" .. wx .. "x" ..(wy+ tambarra).. ", MENUBOX=NO")
    
  -- Ventana decisiones --------------------------------------------------
  
  LBL_banner = set(iup.label{}, posrel(wx, wy, 0, 0, 100, 14) ..
    ", IMAGE=img_clima")
    
  LBL_dia = set(iup.label{}, posrel(wx, wy, 67, 1, 35, 7) ..
    ", TITLE=\" DIA 1\", FONT=Arial:BOLD:20, ALIGNMENT=ALEFT:ATOP, " ..
    "FGCOLOR=\"255 255 255\"")
    
  LBL_jug = set(iup.label{}, posrel(wx, wy, 67, 7, 35, 7) ..
    ", TITLE=\" JUG 1\", FONT=Arial:BOLD:20, ALIGNMENT=ALEFT:ATOP, " ..
    "FGCOLOR=\"255 128 0\"")
    
  LBL_titulo_clima = set(iup.label{}, posrel(wx, wy, 5, 16, 90, 3) ..
    ", TITLE=\" Previsión meteorológica y otros eventos:\", " ..
    "FONT=Arial:BOLD:8, FGCOLOR=\"0 255 255\"")
    
  LBL_clima = set(iup.label{}, posrel(wx, wy, 5, 20, 90, 15) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_titulo_dia = set(iup.label{}, posrel(wx, wy, 5, 36, 90, 3) ..
    ", TITLE=\" Decisiones para la jornada:\", " ..
    "FONT=Arial:BOLD:8, FGCOLOR=\"0 255 255\"")
    
  LBL_coste = set(iup.label{}, posrel(wx, wy, 5, 40, 90, 6) ..
    ", TITLE=\" El coste por limonada es:\", " ..
    "FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_capital = set(iup.label{}, posrel(wx, wy, 5, 47, 90, 3) ..
    ", TITLE=\" El capital actual es de:\", " ..
    "FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_cuantos_vasos = set(iup.label{}, posrel(wx, wy, 5, 55, 45, 5) ..
    ", TITLE=\" Vasos a preparar:\", " ..
    "FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_vasos = set(iup.label{}, posrel(wx, wy, 50, 55, 20, 5) ..
    ", TITLE=\"0\", ALIGNMENT=ACENTER:ACENTER, " ..
    "FONT=Arial:BOLD:12, FGCOLOR=\"255 255 0\"")
    
  BUT_cambiar_vasos = set(iup.button{}, posrel(wx, wy, 80, 54, 15, 7) ..
    ", TITLE=\"+/-\", ALIGNMENT=ACENTER:ACENTER, " ..
    "FONT=Arial:BOLD:12, FGCOLOR=\"0 0 255\"")
  BUT_cambiar_vasos.action = function(self) x_BUT_cambiar_vasos() end
    
  LBL_cuantos_anuncios = set(iup.label{}, posrel(wx, wy, 5, 65, 45, 5) ..
    ", TITLE=\"\", " ..
    "FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_anuncios = set(iup.label{}, posrel(wx, wy, 50, 65, 20, 5) ..
    ", TITLE=\"0\", ALIGNMENT=ACENTER:ACENTER, " ..
    "FONT=Arial:BOLD:12, FGCOLOR=\"0 255 0\"")
    
  BUT_cambiar_anuncios = set(iup.button{}, posrel(wx, wy, 80, 64, 15, 7) ..
    ", TITLE=\"+/-\", ALIGNMENT=ACENTER:ACENTER, " ..
    "FONT=Arial:BOLD:12, FGCOLOR=\"0 0 255\"")
  BUT_cambiar_anuncios.action = function(self) x_BUT_cambiar_anuncios() end
    
  LBL_que_precio = set(iup.label{}, posrel(wx, wy, 5, 75, 45, 5) ..
    ", TITLE=\" Precio por vaso:\", " ..
    "FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_precio = set(iup.label{}, posrel(wx, wy, 50, 75, 20, 5) ..
    ", TITLE=\"0\", ALIGNMENT=ACENTER:ACENTER, " ..
    "FONT=Arial:BOLD:12, FGCOLOR=\"255 128 0\"")
    
  BUT_cambiar_precio = set(iup.button{}, posrel(wx, wy, 80, 74, 15, 7) ..
    ", TITLE=\"+/-\", ALIGNMENT=ACENTER:ACENTER, " ..
    "FONT=Arial:BOLD:12, FGCOLOR=\"0 0 255\"")
  BUT_cambiar_precio.action = function(self) x_BUT_cambiar_precio() end
    
  BUT_decision_OK = set(iup.button{}, posrel(wx, wy, 20, 87, 60, 10) ..
    ", TITLE=\"¡Manos a la obra!\", ALIGNMENT=ACENTER:ACENTER, " ..
    "FONT=Arial:BOLD:12, FGCOLOR=\"0 0 0\"")
  BUT_decision_OK.action = function(self) x_BUT_decision_OK() end
    
  DLG_decisiones = iup.dialog{
    iup.vbox{
      LBL_titulo_clima, LBL_dia, LBL_jug, LBL_banner, LBL_clima,
      LBL_titulo_dia, LBL_coste, LBL_capital,
      LBL_cuantos_vasos, LBL_vasos, BUT_cambiar_vasos,
      LBL_cuantos_anuncios, LBL_anuncios, BUT_cambiar_anuncios,
      LBL_que_precio, LBL_precio, BUT_cambiar_precio, BUT_decision_OK
    }
  }
  set(DLG_decisiones, "TITLE=Limonada, BACKGROUND=img_limonada-bg, " ..
    "BGCOLOR=\"0 50 0\", RASTERSIZE=" .. wx .. "x" ..(wy + tambarra)..
    ", MENUBOX=NO")
    
  -- Ventana Informe -----------------------------------------------------
  
  LBL_banner_inf = set(iup.label{}, posrel(wx, wy, 0, 0, 100, 14) ..
    ", IMAGE=img_informe")
    
  LBL_dia_inf = set(iup.label{}, posrel(wx, wy, 67, 1, 35, 7) ..
    ", TITLE=\" DIA 1\", FONT=Arial:BOLD:20, ALIGNMENT=ALEFT:ATOP, " ..
    "FGCOLOR=\"255 255 255\"")
    
  LBL_jug_inf = set(iup.label{}, posrel(wx, wy, 67, 7, 35, 7) ..
    ", TITLE=\" JUG 1\", FONT=Arial:BOLD:20, ALIGNMENT=ALEFT:ATOP, " ..
    "FGCOLOR=\"255 128 0\"")
    
  LBL_txtvendido = set(iup.label{}, posrel(wx, wy, 5, 20, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_vendido = set(iup.label{}, posrel(wx, wy, 65, 20, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"255 255 255\"")
    
  LBL_txtingresos = set(iup.label{}, posrel(wx, wy, 5, 25, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_ingresos = set(iup.label{}, posrel(wx, wy, 65, 25, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"0 255 0\"")
    
  LBL_txtpreparado = set(iup.label{}, posrel(wx, wy, 5, 35, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_preparado = set(iup.label{}, posrel(wx, wy, 65, 35, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"255 255 255\"")
    
  LBL_txtgastos = set(iup.label{}, posrel(wx, wy, 5, 40, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_gastos = set(iup.label{}, posrel(wx, wy, 65, 40, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"255 128 0\"")
    
  LBL_txtanuncios = set(iup.label{}, posrel(wx, wy, 5, 50, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_anuncios = set(iup.label{}, posrel(wx, wy, 65, 50, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"255 255 255\"")
    
  LBL_txtpubli = set(iup.label{}, posrel(wx, wy, 5, 55, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_publi = set(iup.label{}, posrel(wx, wy, 65, 55, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"255 128 0\"")

  LBL_txtimpuesto = set(iup.label{}, posrel(wx, wy, 5, 60, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"255 255 255\"")
    
  LBL_impuesto = set(iup.label{}, posrel(wx, wy, 65, 60, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"255 128 0\"")
    
  LBL_txtbeneficios = set(iup.label{}, posrel(wx, wy, 5, 75, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"0 255 255\"")
    
  LBL_beneficios = set(iup.label{}, posrel(wx, wy, 65, 75, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"255 255 255\"")
    
  LBL_txtcapitalact = set(iup.label{}, posrel(wx, wy, 5, 80, 60, 4) ..
    ", FONT=Arial:BOLD:8, FGCOLOR=\"0 255 255\"")
    
  LBL_capitalact = set(iup.label{}, posrel(wx, wy, 65, 80, 35, 4) ..
    ", FONT=Arial:BOLD:12, FGCOLOR=\"0 0 255\"")
    
  BUT_informe_OK = set(iup.button{}, posrel(wx, wy, 20, 87, 60, 10) ..
    ", TITLE=\"¡Buenas noches!\", ALIGNMENT=ACENTER:ACENTER, " ..
    "FONT=Arial:BOLD:12, FGCOLOR=\"0 0 0\"")
  BUT_informe_OK.action = function(self) x_BUT_informe_OK() end
    
  DLG_informe = iup.dialog{
    iup.vbox{
      LBL_dia_inf, LBL_jug_inf, LBL_banner_inf,
      LBL_txtvendido, LBL_vendido, LBL_txtingresos, LBL_ingresos,
      LBL_txtpreparado, LBL_preparado, LBL_txtgastos, LBL_gastos,
      LBL_txtanuncios, LBL_anuncios, LBL_txtpubli, LBL_publi,
      LBL_txtimpuesto, LBL_impuesto, LBL_txtbeneficios, LBL_beneficios,
      LBL_txtcapitalact, LBL_capitalact, BUT_informe_OK
    }
  }
  set(DLG_informe, "TITLE=Limonada, BACKGROUND=img_informe-bg, " ..
    "BGCOLOR=\"70 20 20\", RASTERSIZE=" .. wx .. "x" ..(wy + tambarra)..
    ", MENUBOX=NO")
end

--------------------------------------------------------------------------
-- posrel()                                                             --
-- Función para posicionar objetos en proporción al tamaño de ventana.  --
-- Recibe el tamaño de la ventana y la posición y tamaño del objeto en  --
-- forma de tantos por ciento, y devuelve una cadena para IUP del tipo: --
-- "FLOATING=YES, POSITION=\"123,123\", RASTERSIZE=456x456"             --
--------------------------------------------------------------------------

function posrel(wx, wy, x, y, w, h)
  local posx, posy, tamx, tamy, cad
  
  posx = math.floor(wx * x / 100)
  posy = math.floor(wy * y / 100)
  tamx = math.floor(wx * w / 100)
  tamy = math.floor(wy * h / 100)
  cad = "FLOATING=YES, POSITION=\"" .. posx .. "," .. posy .. "\", " ..
        "RASTERSIZE=" .. tamx .. "x" .. tamy
  return cad
end
