# Agentes e economia de tokens

Multiagente custa de 3 a 10 vezes mais tokens que um agente só. Só vale com partes realmente
independentes.

- **Script antes de modelo.** O que é determinístico (contar, mover, diff, git, consultar,
  formatar, mascarar) é script. O modelo só faz julgamento.
- **Escala.** 1 ou 2 itens: faça direto, sem subagente. 3 ou mais independentes: subagentes
  em paralelo, no máximo 4 por vez.
- **Um dono por arquivo.** Cada agente escreve só na sua área; arquivos comuns (índices,
  diário, hubs) são do orquestrador.
- **Passe caminhos, não conteúdo.** A mensagem para o agente leva caminhos e listas; ele lê o
  que precisar.
- **Retorno de uma linha JSON**, com o formato definido na própria definição do agente. Não
  peça detalhe de volta; não reabra o trabalho do agente.
- **Contexto enxuto no agente.** Skill compacta com as convenções no lugar do `CLAUDE.md`
  inteiro, modelo menor para tarefa mecânica, `maxTurns` mínimo, ferramentas só as
  necessárias.
- **Rotina em três tempos.** Script prepara (coleta, promoção, diff, manifesto), modelo julga
  lendo só o manifesto, script fecha (lint, commit, custo). O custo de cada rotina fica
  registrado.
- **Na sessão principal**: `/clear` entre assuntos, subagente para leitura pesada, retomar
  sessão em vez de abrir outra para o mesmo assunto. Cache alto é o principal indicador de
  custo baixo.
