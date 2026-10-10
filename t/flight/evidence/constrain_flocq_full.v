From Stdlib Require Import ZArith Reals Lra.
From Flocq Require Import Core.Raux Core.FLX IEEE754.BinarySingleNaN.
Open Scope Z_scope.
Section Constrain.
Variable prec emax : Z.
Context (Hprec : Prec_gt_0 prec).
Context (Hmax : (prec < emax)%Z).

Definition constrain (v lo hi : binary_float prec emax) : binary_float prec emax :=
  if Bltb v lo then lo else if Bltb hi v then hi else v.

Theorem constrain_spec : forall v lo hi,
  is_finite v = true -> is_finite lo = true -> is_finite hi = true ->
  Bleb lo hi = true ->
  (Bleb lo (constrain v lo hi) = true /\ Bleb (constrain v lo hi) hi = true)
  /\ (Bleb lo v = true -> Bleb v hi = true -> Beqb (constrain v lo hi) v = true)
  /\ (Bltb v lo = true -> Beqb (constrain v lo hi) lo = true)
  /\ (Bltb hi v = true -> Beqb (constrain v lo hi) hi = true).
Proof.
  intros v lo hi Fv Flo Fhi Hle. unfold constrain.
  repeat split; intros;
  destruct (Bltb v lo) eqn:E1; try destruct (Bltb hi v) eqn:E2; cbn in *;
  rewrite ?(Bltb_correct _ _ v lo Fv Flo), ?(Bltb_correct _ _ hi v Fhi Fv),
          ?(Bleb_correct _ _ lo hi Flo Fhi), ?(Bleb_correct _ _ lo v Flo Fv),
          ?(Bleb_correct _ _ v hi Fv Fhi), ?(Bleb_correct _ _ lo lo Flo Flo),
          ?(Bleb_correct _ _ hi hi Fhi Fhi), ?(Bleb_correct _ _ v v Fv Fv),
          ?(Beqb_correct _ _ lo lo Flo Flo), ?(Beqb_correct _ _ hi hi Fhi Fhi),
          ?(Beqb_correct _ _ v v Fv Fv) in *;
  try (apply Rle_bool_true); try (apply Req_bool_true);
  repeat match goal with
    | [ H : Rlt_bool _ _ = _ |- _ ] => revert H; case Rlt_bool_spec; intros
    | [ H : Rle_bool _ _ = _ |- _ ] => revert H; case Rle_bool_spec; intros
  end;
  try reflexivity; try discriminate; try lra; try (exfalso; lra).
Qed.
End Constrain.
