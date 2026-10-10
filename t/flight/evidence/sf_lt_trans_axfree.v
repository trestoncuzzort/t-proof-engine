From Stdlib Require Import ZArith SpecFloat Lia.
Open Scope Z_scope.
Notation lex e e' m m' := (match (e ?= e') with Eq => Pos.compare m m' | c => c end).
Lemma lex_chr : forall e e' m m', lex e e' m m' = Lt <-> e < e' \/ (e = e' /\ (m < m')%positive).
Proof. intros e e' m m'. destruct (e ?= e') eqn:A.
  - apply Z.compare_eq_iff in A. rewrite Pos.compare_lt_iff. split; [right; auto | intros [K|[_ K]]; [lia|exact K]].
  - apply Z.compare_lt_iff in A. split; [left; auto | reflexivity].
  - apply Z.compare_gt_iff in A. split; [discriminate | intros [K|[K _]]; lia]. Qed.
Lemma lex_trans : forall e1 e2 e3 m1 m2 m3, lex e1 e2 m1 m2 = Lt -> lex e2 e3 m2 m3 = Lt -> lex e1 e3 m1 m3 = Lt.
Proof. intros * H1 H2. apply lex_chr in H1; apply lex_chr in H2; apply lex_chr.
  destruct H1 as [?|[??]], H2 as [?|[??]]; [left;lia|left;lia|left;lia|right;split;[lia|eapply Pos.lt_trans;eassumption]]. Qed.
Lemma neg_eq : forall ea eb ma mb,
  (match (ea ?= eb) with Eq => CompOpp (Pos.compare ma mb) | Lt => Gt | Gt => Lt end) = lex eb ea mb ma.
Proof. intros ea eb ma mb. destruct (ea ?= eb) eqn:A, (eb ?= ea) eqn:B;
  pose proof (Z.compare_antisym eb ea) as T; rewrite A, B in T; cbn in T |- *;
  try discriminate T; try reflexivity; symmetry; apply Pos.compare_antisym. Qed.
Lemma sf_lt_trans : forall sa ma ea sb mb eb sc mc ec,
  SFcompare (S754_finite sa ma ea) (S754_finite sb mb eb) = Some Lt ->
  SFcompare (S754_finite sb mb eb) (S754_finite sc mc ec) = Some Lt ->
  SFcompare (S754_finite sa ma ea) (S754_finite sc mc ec) = Some Lt.
Proof. intros. destruct sa, sb, sc; cbn in *; try discriminate; f_equal;
  repeat match goal with [ H : Some _ = Some _ |- _ ] => injection H as H end;
  rewrite ?neg_eq in *; eapply lex_trans; eassumption. Qed.
