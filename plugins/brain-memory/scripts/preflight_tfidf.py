#!/usr/bin/env python3
"""
Pré-filtro TF-IDF para logs de sessão. Só stdlib.

Uso (chamado por /brain-memory:resume antes de gastar tokens):
  python3 preflight_tfidf.py "<query>" --logs-dir <dir> [--top N]

Imprime "<score>\\t<caminho>" dos top-N logs ranqueados por relevância à query,
em ordem decrescente. Query vazia: os N mais recentes por mtime.
Sem --logs-dir, usa $BRAIN_LOGS_DIR.
"""
from __future__ import annotations

import argparse
import math
import os
import re
import sys
from collections import Counter
from pathlib import Path

TOKEN_RE = re.compile(r"[A-Za-zÀ-ÿ][A-Za-zÀ-ÿ0-9_-]{1,}")
STOPWORDS = {
    # PT
    "de", "da", "do", "das", "dos", "e", "o", "a", "os", "as", "um", "uma", "para", "por", "com",
    "que", "se", "na", "no", "nos", "nas", "ao", "aos", "em", "mais", "menos", "sem", "sobre",
    "este", "esta", "isso", "isto", "aquilo", "ele", "ela", "eles", "elas", "como", "quando",
    "onde", "muito", "muita", "muitos", "muitas", "ser", "ter", "fazer",
    # EN
    "the", "an", "and", "or", "but", "of", "to", "in", "on", "for", "with", "at", "by",
    "is", "are", "was", "were", "be", "been", "being", "this", "that", "these", "those",
    "i", "you", "he", "she", "it", "we", "they", "my", "your", "its", "our", "their",
    "from", "not", "does", "did", "have", "has", "had", "will", "would",
    # ruído do formato
    "md", "yaml", "claude", "session", "log", "logs", "quick", "reference",
}


def tokenize(text: str) -> list[str]:
    return [t.lower() for t in TOKEN_RE.findall(text) if t.lower() not in STOPWORDS]


def load_docs(logs_dir: Path) -> list[tuple[Path, str]]:
    if not logs_dir.is_dir():
        return []
    return [(p, p.read_text(encoding="utf-8", errors="ignore")) for p in sorted(logs_dir.glob("*.md"))]


def rank(docs: list[tuple[Path, str]], query: str, top_n: int) -> list[tuple[Path, float]]:
    q_tokens = tokenize(query)
    if not q_tokens:
        scored = [(p, p.stat().st_mtime) for p, _ in docs]
        scored.sort(key=lambda x: x[1], reverse=True)
        return scored[:top_n]

    tfs = [Counter(tokenize(t)) for _, t in docs]
    n = len(docs)
    df: Counter = Counter()
    for tf in tfs:
        df.update(tf.keys())
    idf = {term: math.log((n + 1) / (cnt + 1)) + 1.0 for term, cnt in df.items()}

    scored: list[tuple[Path, float]] = []
    for (path, _), tf in zip(docs, tfs):
        if not tf:
            continue
        max_tf = max(tf.values())
        score = 0.0
        for q in q_tokens:
            tf_q = tf.get(q, 0)
            if tf_q:
                score += (0.5 + 0.5 * tf_q / max_tf) * idf.get(q, 0.0)
        if score > 0:
            scored.append((path, score))
    scored.sort(key=lambda x: x[1], reverse=True)
    return scored[:top_n]


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("query", nargs="?", default="", help="termo opcional")
    ap.add_argument("--top", type=int, default=5)
    ap.add_argument("--logs-dir", type=Path, default=os.environ.get("BRAIN_LOGS_DIR"))
    args = ap.parse_args()

    if not args.logs_dir:
        print("# informe --logs-dir ou BRAIN_LOGS_DIR", file=sys.stderr)
        return 2
    docs = load_docs(Path(args.logs_dir).expanduser())
    if not docs:
        print(f"# nenhum log em {args.logs_dir}", file=sys.stderr)
        return 0

    for path, score in rank(docs, args.query, args.top):
        print(f"{score:.3f}\t{path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
