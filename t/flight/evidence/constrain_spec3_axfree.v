From Stdlib Require Import ZArith SpecFloat.
From Flocq Require Import Core.Raux Core.FLX IEEE754.BinarySingleNaN.
Open Scope Z_scope.
Section S. Variable prec emax : Z. Context (Hprec : Prec_gt_0 prec) (Hmax : (prec<emax)%Z).
Notation bf := (binary_float prec emax).

Lemma cmp_some : forall a b : bf, is_finite a = true -> is_finite b = true ->
  SFcompare (B2SF a) (B2SF b) <> None.
Proof. intros a b Fa Fb. destruct a, b; try discriminate; cbn; discriminate. Qed.
Lemma bleb_refl : forall x : bf, is_finite x = true -> Bleb x x = true.
Proof. intros x Fx. unfold Bleb, SFleb, SFcompare. destruct x; try discriminate; cbn;
  rewrite ?Z.compare_refl, ?Pos.compare_refl; destruct s; reflexivity. Qed.
Lemma beqb_refl : forall x : bf, is_finite x = true -> Beqb x x = true.
Proof. intros x Fx. unfold Beqb, SFeqb, SFcompare. destruct x; try discriminate; cbn;
  rewrite ?Z.compare_refl, ?Pos.compare_refl; destruct s; reflexivity. Qed.
Lemma le_not_lt : forall a b : bf, is_finite a=true -> is_finite b=true -> Bltb a b = false -> Bleb b a = true.
Proof. intros a b Fa Fb H. unfold Bltb, SFltb in H. unfold Bleb, SFleb.
  pose proof (Bcompare_swap _ _ a b) as SW. unfold Bcompare in SW. rewrite SW.
  pose proof (cmp_some a b Fa Fb) as NN.
  destruct (SFcompare (B2SF a) (B2SF b)) as [c|]; [destruct c|]; cbn in *;
  try reflexivity; try discriminate; congruence. Qed.
Lemma le_not_gt : forall a b : bf, is_finite a=true -> is_finite b=true -> Bleb a b = true -> Bltb b a = false.
Proof. intros a b Fa Fb H. unfold Bleb, SFleb in H. unfold Bltb, SFltb.
  pose proof (Bcompare_swap _ _ a b) as SW. unfold Bcompare in SW. rewrite SW.
  destruct (SFcompare (B2SF a) (B2SF b)) as [c|]; [destruct c|]; cbn in *;
  try reflexivity; try discriminate. Qed.

Definition constrain (v lo hi : bf) : bf :=
  if Bltb v lo then lo else if Bltb hi v then hi else v.

Theorem constrain_spec3 : forall v lo hi : bf,
  is_finite v=true -> is_finite lo=true -> is_finite hi=true -> Bleb lo hi = true ->
  (Bleb lo (constrain v lo hi) = true /\ Bleb (constrain v lo hi) hi = true)
  /\ (Bleb lo v = true -> Bleb v hi = true -> Beqb (constrain v lo hi) v = true)
  /\ (Bltb v lo = true -> Beqb (constrain v lo hi) lo = true).
Proof.
  intros v lo hi Fv Flo Fhi Hle. unfold constrain. repeat split.
  - destruct (Bltb v lo) eqn:E1; [|destruct (Bltb hi v) eqn:E2]; cbn;
    [ apply bleb_refl; exact Flo | exact Hle | exact (le_not_lt _ _ Fv Flo E1) ].
  - destruct (Bltb v lo) eqn:E1; [|destruct (Bltb hi v) eqn:E2]; cbn;
    [ exact Hle | apply bleb_refl; exact Fhi | exact (le_not_lt _ _ Fhi Fv E2) ].
  - intros H1 H2. rewrite (le_not_gt _ _ Flo Fv H1). rewrite (le_not_gt _ _ Fv Fhi H2).
    cbn. apply beqb_refl; exact Fv.
  - intros H. rewrite H. cbn. apply beqb_refl; exact Flo.
Qed.
End S.
Print Assumptions constrain_spec3.
