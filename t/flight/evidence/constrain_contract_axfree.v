From Stdlib Require Import ZArith SpecFloat Lia.
From Flocq Require Import Core.FLX IEEE754.BinarySingleNaN.
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
Section S. Variable prec emax : Z. Context (Hprec : Prec_gt_0 prec) (Hmax : (prec<emax)%Z).
Notation bf := (binary_float prec emax).
Lemma cmp_some : forall a b : bf, is_finite a=true -> is_finite b=true -> SFcompare (B2SF a) (B2SF b) <> None.
Proof. intros a b Fa Fb. destruct a, b; try discriminate; cbn; discriminate. Qed.
Lemma bleb_refl : forall x : bf, is_finite x=true -> Bleb x x = true.
Proof. intros x Fx. unfold Bleb, SFleb, SFcompare. destruct x; try discriminate; cbn;
  rewrite ?Z.compare_refl, ?Pos.compare_refl; destruct s; reflexivity. Qed.
Lemma beqb_refl : forall x : bf, is_finite x=true -> Beqb x x = true.
Proof. intros x Fx. unfold Beqb, SFeqb, SFcompare. destruct x; try discriminate; cbn;
  rewrite ?Z.compare_refl, ?Pos.compare_refl; destruct s; reflexivity. Qed.
Lemma le_not_lt : forall a b : bf, is_finite a=true -> is_finite b=true -> Bltb a b = false -> Bleb b a = true.
Proof. intros a b Fa Fb H. unfold Bltb, SFltb in H. unfold Bleb, SFleb.
  pose proof (Bcompare_swap _ _ a b) as SW. unfold Bcompare in SW. rewrite SW.
  pose proof (cmp_some a b Fa Fb) as NN.
  destruct (SFcompare (B2SF a) (B2SF b)) as [c|]; [destruct c|]; cbn in *; try reflexivity; try discriminate; congruence. Qed.
Lemma le_not_gt : forall a b : bf, is_finite a=true -> is_finite b=true -> Bleb a b = true -> Bltb b a = false.
Proof. intros a b Fa Fb H. unfold Bleb, SFleb in H. unfold Bltb, SFltb.
  pose proof (Bcompare_swap _ _ a b) as SW. unfold Bcompare in SW. rewrite SW.
  destruct (SFcompare (B2SF a) (B2SF b)) as [c|]; [destruct c|]; cbn in *; try reflexivity; try discriminate. Qed.
Lemma blt_iff : forall a b : bf, Bltb a b = true <-> SFcompare (B2SF a) (B2SF b) = Some Lt.
Proof. intros a b. unfold Bltb, SFltb. destruct (SFcompare (B2SF a) (B2SF b)) as [[]|]; split; (reflexivity||discriminate). Qed.
Lemma blt_trans : forall a b c : bf, is_finite a=true -> is_finite b=true -> is_finite c=true ->
  Bltb a b = true -> Bltb b c = true -> Bltb a c = true.
Proof. intros a b c Fa Fb Fc H1 H2. rewrite blt_iff in *.
  destruct a, b, c; cbn [B2SF is_finite] in *; try discriminate;
    try (eapply sf_lt_trans; eassumption);
    repeat match goal with [ x : bool |- _ ] => destruct x end; cbn in *; try discriminate; try reflexivity. Qed.
Definition constrain (v lo hi : bf) : bf := if Bltb v lo then lo else if Bltb hi v then hi else v.
Theorem constrain_spec : forall v lo hi : bf,
  is_finite v=true -> is_finite lo=true -> is_finite hi=true -> Bleb lo hi = true ->
  (Bleb lo (constrain v lo hi) = true /\ Bleb (constrain v lo hi) hi = true)
  /\ (Bleb lo v = true -> Bleb v hi = true -> Beqb (constrain v lo hi) v = true)
  /\ (Bltb v lo = true -> Beqb (constrain v lo hi) lo = true)
  /\ (Bltb hi v = true -> Beqb (constrain v lo hi) hi = true).
Proof.
  intros v lo hi Fv Flo Fhi Hle. unfold constrain. repeat split.
  - destruct (Bltb v lo) eqn:E1; [|destruct (Bltb hi v) eqn:E2]; cbn;
    [ apply bleb_refl; exact Flo | exact Hle | exact (le_not_lt _ _ Fv Flo E1) ].
  - destruct (Bltb v lo) eqn:E1; [|destruct (Bltb hi v) eqn:E2]; cbn;
    [ exact Hle | apply bleb_refl; exact Fhi | exact (le_not_lt _ _ Fhi Fv E2) ].
  - intros H1 H2. rewrite (le_not_gt _ _ Flo Fv H1), (le_not_gt _ _ Fv Fhi H2). cbn. apply beqb_refl; exact Fv.
  - intros H. rewrite H. cbn. apply beqb_refl; exact Flo.
  - intros Hhv. destruct (Bltb v lo) eqn:E1; cbn.
    + exfalso. assert (C := blt_trans _ _ _ Fhi Fv Flo Hhv E1).
      rewrite (le_not_gt _ _ Flo Fhi Hle) in C. discriminate C.
    + rewrite Hhv. cbn. apply beqb_refl; exact Fhi.
Qed.
End S.
Print Assumptions constrain_spec.
