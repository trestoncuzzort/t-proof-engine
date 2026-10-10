From Stdlib Require Import ZArith SpecFloat.
From Flocq Require Import Core.Raux Core.FLX IEEE754.BinarySingleNaN.
Open Scope Z_scope.
Section S. Variable prec emax : Z. Context (Hprec : Prec_gt_0 prec) (Hmax : (prec<emax)%Z).
Notation bf := (binary_float prec emax).

Lemma bleb_refl : forall x : bf, is_finite x = true -> Bleb x x = true.
Proof. intros x Fx. unfold Bleb, SFleb, SFcompare. destruct x; try discriminate; cbn;
  rewrite ?Z.compare_refl, ?Pos.compare_refl; destruct s; reflexivity. Qed.

Lemma cmp_some : forall a b : bf, is_finite a = true -> is_finite b = true ->
  SFcompare (B2SF a) (B2SF b) <> None.
Proof. intros a b Fa Fb. destruct a, b; try discriminate; cbn; discriminate. Qed.

Lemma le_not_lt : forall a b : bf, is_finite a = true -> is_finite b = true ->
  Bltb a b = false -> Bleb b a = true.
Proof. intros a b Fa Fb H. unfold Bltb, SFltb in H. unfold Bleb, SFleb.
  pose proof (Bcompare_swap _ _ a b) as SW. unfold Bcompare in SW. rewrite SW.
  pose proof (cmp_some a b Fa Fb) as NN.
  destruct (SFcompare (B2SF a) (B2SF b)) as [c|]; [destruct c|]; cbn in *;
  try reflexivity; try discriminate; congruence. Qed.

Definition constrain (v lo hi : bf) : bf :=
  if Bltb v lo then lo else if Bltb hi v then hi else v.

Theorem constrain_bounds : forall v lo hi : bf,
  is_finite v = true -> is_finite lo = true -> is_finite hi = true ->
  Bleb lo hi = true ->
  Bleb lo (constrain v lo hi) = true /\ Bleb (constrain v lo hi) hi = true.
Proof.
  intros v lo hi Fv Flo Fhi Hle. unfold constrain.
  destruct (Bltb v lo) eqn:E1; [| destruct (Bltb hi v) eqn:E2]; cbn; split.
  - apply bleb_refl; exact Flo.
  - exact Hle.
  - exact Hle.
  - apply bleb_refl; exact Fhi.
  - exact (le_not_lt _ _ Fv Flo E1).
  - exact (le_not_lt _ _ Fhi Fv E2).
Qed.
End S.
Print Assumptions constrain_bounds.
