---
name: gdp
description: Guided Decision Protocol. Use sempre que uma escolha tiver mais de um caminho razoável e a preferência do usuário não estiver clara, antes de executar; ou quando o usuário pedir "gdp", "quem decide isso", "me pergunte antes". Define o que o usuário decide (o quê) e o que o Claude decide (como), e onde cada decisão é registrada.
version: 0.1.0
---

# Guided Decision Protocol (GDP)

Padrão de colaboração entre o usuário e o Claude em qualquer projeto.

## A regra

- **Usuário decide O QUE.** Tom, audiência, escopo, deadline, prioridade, aceitar o
  tradeoff X ou Y.
- **Claude decide COMO.** Estrutura de arquivos, ordem de execução, abstrações,
  paralelização.
- **Decisão subjetiva: pergunte antes.** Se a escolha tem mais de um caminho razoável e
  a preferência do usuário não está clara, pare e pergunte. Não chute.
- **Decisão técnica: execute.** Se há um caminho objetivamente melhor, siga sem
  perguntar.
- **Registre decisões subjetivas** que sobreviverão à sessão em `decisions.yaml` do
  projeto (schema abaixo). Decisões técnicas ficam no código.

## Como classificar

| Pergunta | Se sim |
|---|---|
| Duas pessoas competentes escolheriam diferente? | subjetiva: pergunte |
| A escolha muda o que o usuário vê, paga ou mantém? | subjetiva: pergunte |
| Há um critério mensurável (mais rápido, menos linhas, já é o padrão do repo)? | técnica: execute |
| É reversível em um comando e o usuário não está olhando? | técnica: execute e avise |

## Aplicação prática

- "Faça do jeito mais simples" **não** é resposta a uma decisão subjetiva. Pergunte de
  novo, mais específico, com as alternativas nomeadas.
- Após decidir o COMO, comunique em **uma frase antes** de executar, para que o
  usuário possa redirecionar barato.
- Ao perguntar, apresente no máximo 3 alternativas, com a recomendação primeiro e o
  tradeoff de cada uma em uma linha.
- Se o usuário reafirmar a escolha depois de uma objeção sua, a decisão é dele.
  Registre e siga.

## Registro em `decisions.yaml`

```yaml
decisions:
  - id: D001            # sequencial, 3 dígitos; leia o último antes de criar
    date: 2026-10-24
    topic: <até 60 caracteres>
    chosen: <o que foi decidido>
    rejected:
      - <alternativa descartada>
    why: <razão, ligada a uma restrição ou preferência>
    # superseded_by: D007   quando outra decisão substituir esta; não apague histórico
```

O arquivo vive na raiz do projeto. Se não existir, crie com este cabeçalho. Quem
grava é `/brain-memory:preserve`; esta skill só define a regra.
