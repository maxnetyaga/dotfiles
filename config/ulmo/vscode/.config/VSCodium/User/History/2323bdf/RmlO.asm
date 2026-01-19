include masm32rt.inc
public NetyagaDenominatorNetyaga
extern netyaga_d_vals:qword, netyaga_a_vals:qword
.code
    NetyagaDenominatorNetyaga proc
        fld netyaga_d_vals[esi]
        fld netyaga_a_vals[esi]
        fsubp st(1), st(0)
        fld [fp_one]
        faddp st(1), st(0)
        ret
    NetyagaDenominatorNetyaga endp