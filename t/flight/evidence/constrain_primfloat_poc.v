(* Comparison-only float task via Rocq PRIMITIVE floats: literals, native computable order, and vm_compute
   refutation -- the shape a generator can emit and a measured witness can refute by computation. *)
From Stdlib Require Import Floats.
Open Scope float_scope.

Definition constrain (v lo hi : float) : float :=
  if v <? lo then lo else if hi <? v then hi else v.

(* real task: body and spec share the same order, so each clamp property is definitional *)
Theorem constrain_below : forall v lo hi, (v <? lo) = true -> constrain v lo hi = lo.
Proof. intros v lo hi H. unfold constrain. rewrite H. reflexivity. Qed.
Theorem constrain_above : forall v lo hi, (v <? lo) = false -> (hi <? v) = true -> constrain v lo hi = hi.
Proof. intros v lo hi H1 H2. unfold constrain. rewrite H1, H2. reflexivity. Qed.
Theorem constrain_within : forall v lo hi, (v <? lo) = false -> (hi <? v) = false -> constrain v lo hi = v.
Proof. intros v lo hi H1 H2. unfold constrain. rewrite H1, H2. reflexivity. Qed.

(* twin: a mutant returning hi on the low branch; refuted at a measured witness by computation *)
Definition constrain_twin (v lo hi : float) : float :=
  if v <? lo then hi else if hi <? v then hi else v.
Example twin_refuted_at_witness : (constrain_twin 0 1 2 =? 1) = false.
Proof. vm_compute. reflexivity. Qed.
