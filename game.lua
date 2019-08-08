-- author: Diego Soria Rios
-- desc:   RPG
-- script: lua

placar = {
	derrotas = 0 ,
	vitorias = 0
}

objetos = {}

Constantes = {
	MAGIC_NUMBER = 8 ,
	LARGURA_DA_TELA = 240 ,
	ALTURA_DA_TELA = 138 ,
	OBSTACULOS = 128 ,
	VELOCIDADE_ANIMACAO_JOGADOR = 0.1 ,
	VELOCIDADE_INIMIGO = 0.5 ,

	SPRITE_JOGADOR = 260 ,
	SPRITE_CORACAO = 428 ,
	SPRITE_CHAVE = 364 ,
	SPRITE_PORTA = 366 ,
	SPRITE_INIMIGO = 292 ,
	SPRITE_TITULO = 352 ,
	SPRITE_TITULO_LARGURA = 12 ,
	SPRITE_TITULO_ALTURA = 4 ,
	SPRITE_ALURA = 416 ,
	SPRITE_ALURA_LARGURA = 7 ,
	SPRITE_ALURA_ALTURA = 3 ,

	ID_SFX_CHAVE = 0 ,
	ID_SFX_PORTA = 1 ,
	ID_SFX_INICIO = 2 ,
	ID_SFX_CORACAO = 3 ,
	ID_SFX_MORTE = 4 ,

	INIMIGO = "INIMIGO" ,
	JOGADOR = "JOGADOR" ,

	Direcao = {
		CIMA = 1 ,
		BAIXO = 2 ,
		ESQUERDA = 3 ,
		DIREITA = 4
	} ,

	Posicao = {
		PRIMEIRA_PARTE = 1 ,
		SEGUNDA_PARTE = 2 ,
		TANTO_FAZ = 3
	 }
}

function temColisaoComMapa(ponto)
	local blocoX = ponto.x / Constantes.MAGIC_NUMBER
	local blocoY = ponto.y / Constantes.MAGIC_NUMBER

	local blocoId = mget( blocoX ,	blocoY )

	if blocoId >= Constantes.OBSTACULOS then
		return true
	end

	return false
end

function tentaMoverPara( personagem , delta )
	local novaPosicao = {
		x = personagem.x + delta.deltaX ,
		y = personagem.y + delta.deltaY
	}

	if verificaColisaoComObjetos( personagem , novaPosicao ) then
		return
	end

	local superiorDireito = {
		x = personagem.x - 8 + delta.deltaX ,
		y = personagem.y - 8 + delta.deltaY
	}

	local superiorEsquerdo = {
		x = personagem.x + 7 + delta.deltaX ,
		y = personagem.y - 8 + delta.deltaY
	}

	local inferiorDireito = {
		x = personagem.x + 7 + delta.deltaX ,
		y = personagem.y + 7 + delta.deltaY
	}

	local inferiorEsquerdo = {
		x = personagem.x - 8 + delta.deltaX ,
		y = personagem.y + 7 + delta.deltaY
	}

	if not ( temColisaoComMapa( superiorDireito )
		or temColisaoComMapa( superiorEsquerdo )
		or temColisaoComMapa( inferiorDireito )
		or temColisaoComMapa( inferiorEsquerdo ) ) then
		personagem.quadroDeAnimacao = personagem.quadroDeAnimacao + Constantes.VELOCIDADE_ANIMACAO_JOGADOR

		if personagem.quadroDeAnimacao >= 3 then
			personagem.quadroDeAnimacao = 1
		end

		personagem.y = personagem.y + delta.deltaY
		personagem.x = personagem.x + delta.deltaX
	end
end

function atualizaInimigo( inimigo )
	local delta = {
		deltaY = 0 ,
		deltaX = 0
	}

	local AnimacaoInimigo = {
		{ 288 , 290 } ,
		{ 292 , 294 } ,
		{ 296 , 298 } ,
		{ 300 , 302 } 
	}

	if jogador.y > inimigo.y then
		delta.deltaY = Constantes.VELOCIDADE_INIMIGO
		inimigo.direcao = Constantes.Direcao.BAIXO
	elseif jogador.y < inimigo.y then
		delta.deltaY = -Constantes.VELOCIDADE_INIMIGO
		inimigo.direcao = Constantes.Direcao.CIMA
	end

	tentaMoverPara( inimigo , delta )
	delta.deltaY = 0

	if jogador.x > inimigo.x then
		delta.deltaX = Constantes.VELOCIDADE_INIMIGO
		inimigo.direcao = Constantes.Direcao.DIREITA
	elseif jogador.x < inimigo.x then
		delta.deltaX = -Constantes.VELOCIDADE_INIMIGO
		inimigo.direcao = Constantes.Direcao.ESQUERDA
	end

	tentaMoverPara( inimigo , delta )

	local quadros = AnimacaoInimigo[inimigo.direcao]
	local quadro = math.floor(inimigo.quadroDeAnimacao)
	inimigo.sprite = quadros[quadro]
end

function atualizaOJogo()

	local Direcao = {
		{ deltaX =  0 , deltaY = -1 } ,
		{ deltaX =  0 , deltaY =  1 } ,
		{ deltaX = -1 , deltaY =  0 } ,
		{ deltaX =  1 , deltaY =  0 }
	}

	local AnimacaoJogador = {
		{ 256 , 258 },
		{ 260 , 262 },
		{ 264 , 266 },
		{ 268 , 270 }
	}

	for tecla = 0 , 3 do
		if btn( tecla ) then
			local quadros = AnimacaoJogador[tecla+1]
			local quadro = math.floor(jogador.quadroDeAnimacao)
			jogador.sprite = quadros[quadro]
			tentaMoverPara( jogador ,  Direcao[tecla+1] )
		end
	end

	verificaColisaoComObjetos( jogador, { x = jogador.x , y = jogador.y } )

	for indice , objeto in pairs( objetos ) do
		if objeto.tipo == Constantes.INIMIGO then
			atualizaInimigo( objeto )
		end
	end
	--movimentacao vertical
	--if btn(0) then
		--cima
		--tentaMoverPara( 0 , -1 )
	--end

	--if btn(1) then
		--baixo
		--tentaMoverPara( 0 , 1 )
	--end

	--movimentacao horizontal
	--if btn(2) then
		--esquerda
		--tentaMoverPara( -1 , 0 )
	--end

	--if btn(3) then
		--direita
		--tentaMoverPara( 1 , 0 )
	--end
end

function criaInimigo( coluna , linha )
	local inimigo = {
		sprite = Constantes.SPRITE_INIMIGO ,
		x = coluna * Constantes.MAGIC_NUMBER + Constantes.MAGIC_NUMBER ,
		y = linha * Constantes.MAGIC_NUMBER + Constantes.MAGIC_NUMBER ,
		corDeFundo = 14 ,
		quadroDeAnimacao = 1 ,
		tipo = Constantes.INIMIGO ,
		direcao = 0 ,
		colisoes = {
			INIMIGO = deixaPassar ,
			JOGADOR = fazColisaoDoJogadorComOInimigo
		}
	--funcaoDeColisao = fazColisaoDoJogadorComOInimigo
	}

	return inimigo
end

function criaPorta( coluna , linha )
	local porta = {
		sprite = Constantes.SPRITE_PORTA ,
		x = coluna * Constantes.MAGIC_NUMBER + Constantes.MAGIC_NUMBER ,
		y = linha * Constantes.MAGIC_NUMBER + Constantes.MAGIC_NUMBER ,
		corDeFundo = 6 ,
		--funcaoDeColisao = fazColisaoDoJogadorComAPorta
		colisoes = {
			INIMIGO = fazColisaoDoInimigoComAPorta ,
			JOGADOR = fazColisaoDoJogadorComAPorta
		}
	}

	return porta
end

function criaChave( coluna , linha )
	local chave = {
		sprite = Constantes.SPRITE_CHAVE ,
		x = coluna * Constantes.MAGIC_NUMBER + Constantes.MAGIC_NUMBER ,
		y = linha * Constantes.MAGIC_NUMBER + Constantes.MAGIC_NUMBER ,
		corDeFundo = 6 ,
		colisoes = {
			INIMIGO = deixaPassar ,
			JOGADOR = fazColisaoDoJogadorComAChave
		}
		--funcaoDeColisao = fazColisaoDoJogadorComAChave
	}

	return chave
end

function criaCoracao( coluna , linha )
	local coracao = {
		sprite = Constantes.SPRITE_CORACAO ,
		x = coluna * Constantes.MAGIC_NUMBER + Constantes.MAGIC_NUMBER ,
		y = linha * Constantes.MAGIC_NUMBER + Constantes.MAGIC_NUMBER ,
		corDeFundo = 14 ,
		colisoes = {
			INIMIGO = deixaPassar ,
			JOGADOR = fazColisaoDoJogadorComOCoracao
		}
		--funcaoDeColisao = fazColisaoDoJogadorComAChave
	}

	return coracao
end

function desenhaMapa()
	map(0,   --posicao x no mapa
		0,   --posicao y no mapa 
		Constantes.LARGURA_DA_TELA, --quanto desenhar de x
		Constantes.ALTURA_DA_TELA, --quanto desenhar de y
		0,   --em qual ponto colocar o x
		0    --em qual ponto colocar o y
	)
end

function desenhaJogador()
	spr(jogador.sprite, --sprite utilizado
		jogador.x - Constantes.MAGIC_NUMBER,  --posicao horizontal
		jogador.y - Constantes.MAGIC_NUMBER,  --posicao vertical
		jogador.corDeFundo, --cor de fundo
		1, --escala
		0, --espelhar
		0, --rotacionar
		2, --quantos blocos para direita
		2 --quantos blocos para baixo
	) 
end

function desenhaObjetos()
	for indice , objeto in pairs( objetos ) do
		spr(objeto.sprite, --sprite utilizado
			objeto.x - Constantes.MAGIC_NUMBER,  --posicao horizontal
			objeto.y - Constantes.MAGIC_NUMBER,  --posicao vertical
			objeto.corDeFundo, --cor de fundo
			1, --escala
			0, --espelhar
			0, --rotacionar
			2, --quantos blocos para direita
			2
		) --quantos blocos para baixo
	end
end

function desenhaOJogo()
	cls() --limpa a tela
	desenhaMapa()
	desenhaJogador()
	desenhaObjetos()
	--print(jogador.x)
	--print(jogador.y)
	--print(mget((jogador.x-8) / 8, (jogador.y-8) / 8), --valor
			--0, --coluna
			--6 --linha
			--)
end

function atualizaATelaDeTitulo()
	if btn(4) then
		sfx( Constantes.ID_SFX_INICIO ,
			72 , --Notas
			32 , --Tempo
			00 , --Canal
			08 , --Volume
			00   --Velocidade
		)
		tela = Tela.JOGO
	end
end

function desenhaATelaDeTitulo()
	cls()
	spr( Constantes.SPRITE_TITULO , --sprite utilizado
		80 , --posicao horizontal
		10 , --posicao vertical
		0 , --cor de fundo
		1 , --escala
		0 , --espelhar
		0 , --rotacionar
		Constantes.SPRITE_TITULO_LARGURA , --quantos blocos para direita
		Constantes.SPRITE_TITULO_ALTURA --quantos blocos para baixo
	)

	spr( Constantes.SPRITE_ALURA , --sprite utilizado
		94 , --posicao horizontal
		92 , --posicao vertical
		0 , --cor de fundo
		1 , --escala
		0 , --espelhar
		0 , --rotacionar
		Constantes.SPRITE_ALURA_LARGURA , --quantos blocos para direita
		Constantes.SPRITE_ALURA_ALTURA --quantos blocos para baixo
	)

	print( "Placar" , 105 , 60 , 09 )
	print( "_______" , 105 , 62 , 09 )
	print( "Derrotas: " .. placar.derrotas , 90 , 70 , 06 )
	print( "Vitorias: " .. placar.vitorias , 90 , 80 , 05 )
	print( "www.alura.com.br" , 78 , 122 , 15 )
	print( "Daniel Mendes" , 85 , 130 )
end

function fazColisaoDoJogadorComOCoracao( indice )
	placar.vitorias = placar.vitorias + 1
	sfx( Constantes.ID_SFX_CORACAO ,
		60 , --Notas
		32 , --Tempo
		00 , --Canal
		08 , --Volume
		-01  --Velocidade
	)
	inicializa()
	return true
end

function fazColisaoDoJogadorComOInimigo( indice )
	placar.derrotas = placar.derrotas + 1
	sfx( Constantes.ID_SFX_MORTE ,
		60 , --Notas
		32 , --Tempo
		00 , --Canal
		08 , --Volume
		00   --Velocidade
	)
	inicializa()
	return true
end

function deixaPassar( indice )
	return false
end

function fazColisaoDoJogadorComAChave( indice )
	table.remove( objetos, indice )
	jogador.chaves = jogador.chaves + 1
	sfx( Constantes.ID_SFX_CHAVE ,
		60 , --Notas
		32 , --Tempo
		00 , --Canal
		08 , --Volume
		01   --Velocidade
	)

	return false
end

function fazColisaoDoInimigoComAPorta( indice )
	return true
end
	
function fazColisaoDoJogadorComAPorta( indice )
	if jogador.chaves > 0 then
		jogador.chaves = jogador.chaves - 1
		table.remove( objetos, indice )
		sfx( Constantes.ID_SFX_PORTA ,
			60 , --Notas
			32 , --Tempo
			00 , --Canal
			08 , --Volume
			01   --Velocidade
		)
		return false
	end

	return true
end

function temColisao( objetoA , objetoB )
	local esquerdaDeB = objetoB.x - 8
	local direitaDeB = objetoB.x + 7
	local cimaDeB = objetoB.y - 8
	local baixoDeB = objetoB.y + 7

	local esquerdaDeA = objetoA.x - 8
	local direitaDeA = objetoA.x + 7
	local cimaDeA = objetoA.y - 8
	local baixoDeA = objetoA.y + 7

	if esquerdaDeB > direitaDeA or
		direitaDeB < esquerdaDeA or
		baixoDeA  < cimaDeB or
		cimaDeA > baixoDeB then
		return false
	end

	return true
end

function verificaColisaoComObjetos( personagem , novaPosicao )

	for indice, objeto in pairs(objetos) do
		if temColisao( novaPosicao , objeto ) then
			local funcaoDeColisao = objeto.colisoes[ personagem.tipo ]
			return funcaoDeColisao( indice )
		end
	end

	return false
end

Tela = {
	INICIO = {
		atualiza = atualizaATelaDeTitulo ,
		desenha = desenhaATelaDeTitulo
	} ,
	JOGO   = {
		atualiza = atualizaOJogo ,
		desenha = desenhaOJogo
	}
}

function colunaAleatoria( posicao )
	local coluna = 0

	if posicao == Constantes.Posicao.PRIMEIRA_PARTE or
		( posicao ~= Constantes.Posicao.SEGUNDA_PARTE and math.ceil( math.random( 1 , 2 ) ) == Constantes.Posicao.PRIMEIRA_PARTE ) then
		coluna = math.random( 02 , 16 )
	else
		coluna = math.random( 21 , 27 )
	end

	return coluna
end

function linhaAleatoria()
	local linha = 0

	linha = math.random( 02 , 14 )

	return linha
end

function pontosParaVerificar( ponto )
	local pontos

	pontos = {
		{ x = ponto.x + Constantes.MAGIC_NUMBER ,
		  y = ponto.y + Constantes.MAGIC_NUMBER } ,
		{ x = ponto.x - Constantes.MAGIC_NUMBER ,
		  y = ponto.y - Constantes.MAGIC_NUMBER } ,
		{ x = ponto.x - Constantes.MAGIC_NUMBER ,
		  y = ponto.y + Constantes.MAGIC_NUMBER } ,
		{ x = ponto.x + Constantes.MAGIC_NUMBER ,
		  y = ponto.y - Constantes.MAGIC_NUMBER }
	}

	return pontos
end

function coordenadasAleatorias( posicao , x , y , multiplica )
	local ponto = { x = 0 , y = 0 }
	local pontos
	local colidiu = 0
	local forcaXY = false
	local valor = 0

	if multiplica then
		valor = Constantes.MAGIC_NUMBER
	else
		valor = 1
	end

	ponto.x = colunaAleatoria( posicao ) * Constantes.MAGIC_NUMBER
	ponto.y = linhaAleatoria() * Constantes.MAGIC_NUMBER
	pontos = pontosParaVerificar( ponto )
  
	while temColisaoComMapa( ponto ) or
		temColisaoComMapa( pontos[ 1 ] ) or
		temColisaoComMapa( pontos[ 2 ] ) or
		temColisaoComMapa( pontos[ 3 ] ) or
		temColisaoComMapa( pontos[ 4 ] ) do
		ponto.x = colunaAleatoria( posicao )
		ponto.y = linhaAleatoria()
		pontos = pontosParaVerificar( ponto )
		colidiu = colidiu + 1

		--Evitar loop infinito
		if colidiu > 10000 then
			forcaXY = true
			break
		end
	end

	if forcaXY then
		ponto.x = x
		ponto.y = y
	else
		ponto.x = ponto.x / valor
		ponto.y = ponto.y / valor
	end

	return ponto
end

function inicializa()
	local posicao

	local porta = criaPorta( 20 , 07 )

	posicao = coordenadasAleatorias( Constantes.Posicao.PRIMEIRA_PARTE , 3 , 3 , true )

	local chave = criaChave( posicao.x , posicao.y )

	posicao = coordenadasAleatorias( Constantes.Posicao.SEGUNDA_PARTE , 25 , 8 , true )

	local coracao = criaCoracao( posicao.x , posicao.y )

	posicao = coordenadasAleatorias( Constantes.Posicao.TANTO_FAZ , 26 , 13 , true )

	local inimigo = criaInimigo( posicao.x , posicao.y )
	--local chave = criaChave( 03 , 03 )
	--local inimigo = criaInimigo( 26 , 13 )
	--local coracao = criaCoracao( 25 , 08 )

	posicao = coordenadasAleatorias( Constantes.Posicao.PRIMEIRA_PARTE , 95 , 95 , false )

	objetos = {}

	jogador = {
		sprite = Constantes.SPRITE_JOGADOR ,
		--x = 95 ,
		--y = 95 ,
		x = posicao.x ,
		y = posicao.y ,
		corDeFundo = 6 ,
		quadroDeAnimacao = 1 ,
		chaves = 0 ,
		tipo = Constantes.JOGADOR
	}

	table.insert( objetos , chave )
	table.insert( objetos , porta )
	table.insert( objetos , inimigo )
	table.insert( objetos , coracao )

	tela = Tela.INICIO
end

inicializa()

function TIC()
	--if tela == Tela.INICIO then
		--atualizaATelaDeTitulo()
		--desenhaATelaDeTitulo()
	--end
	--if tela == Tela.JOGO then
		--atualizaOJogo()
		--verificaColisaoComObjetos( jogador )
		--desenhaOJogo()
	--end

	tela.atualiza()
	tela.desenha()
end
