(* Proof-of-concept: PX4 math::constrain at IEEE-754 binary64, the comparison-only float shape, proved in Rocq via
   Flocq. Body and spec use the same float order (Flocq Bcompare), so correctness is a direct case analysis -- exactly
   what dawnr's twin rule checks: the t program satisfies its t specification. Demonstrates the Rocq-via-Flocq route. *)
From Stdlib Require Import ZArith.
From Flocq Require Import IEEE754.Binary.
Open Scope Z_scope.

Definition b64 := binary_float 53 1024.                                   (* IEEE-754 binary64 *)
Definition lt64 (a b : b64) : bool :=
  match Bcompare 53 1024 a b with Some Lt => true | _ => false end.

Definition constrain (v lo hi : b64) : b64 :=
  if lt64 v lo then lo else if lt64 hi v then hi else v.

Theorem constrain_below : forall v lo hi, lt64 v lo = true -> constrain v lo hi = lo.
Proof. intros v lo hi H. unfold constrain. rewrite H. reflexivity. Qed.

Theorem constrain_above : forall v lo hi, lt64 v lo = false -> lt64 hi v = true -> constrain v lo hi = hi.
Proof. intros v lo hi H1 H2. unfold constrain. rewrite H1, H2. reflexivity. Qed.

Theorem constrain_within : forall v lo hi, lt64 v lo = false -> lt64 hi v = false -> constrain v lo hi = v.
Proof. intros v lo hi H1 H2. unfold constrain. rewrite H1, H2. reflexivity. Qed.
