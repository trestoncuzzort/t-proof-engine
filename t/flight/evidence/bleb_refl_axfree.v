From Stdlib Require Import ZArith SpecFloat.
From Flocq Require Import Core.Raux Core.FLX IEEE754.BinarySingleNaN.
Open Scope Z_scope.
Section S. Variable prec emax : Z. Context (Hprec : Prec_gt_0 prec) (Hmax : (prec<emax)%Z).
Lemma bleb_refl : forall x : binary_float prec emax, is_finite x = true -> Bleb x x = true.
Proof. intros x Fx. unfold Bleb, SFleb, SFcompare. destruct x; try discriminate; cbn;
  rewrite ?Z.compare_refl, ?Pos.compare_refl; destruct s; reflexivity. Qed.
End S.
Print Assumptions bleb_refl.
