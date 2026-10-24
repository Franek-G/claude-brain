# Testes

- Toda correção de bug vem com um teste que **falhava antes e passa depois**. Sem o
  teste, a correção não está pronta.
- Rode a suíte relevante antes de dizer "pronto" e cole a saída, inclusive quando
  falhar. Não resuma um teste que você não rodou.
- Regra mecânica (formato, lint, invariante de arquivo) vira teste ou check
  determinístico, não instrução para revisor humano ou IA.
- Teste o comportamento, não a implementação. Mock só na fronteira (rede, relógio,
  sistema de arquivos).
