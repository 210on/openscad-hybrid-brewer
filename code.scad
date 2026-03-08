// ハリオスイッチ風 ドリッパー＆台座 断面モデル

/* [表示とカラー設定] */

// 断面表示の切り替え (true: 断面表示, false: 全体表示)
show_cross_section = true;

// 台座の断面色 [R, G, B, Alpha]
color_cut_silicone = [0.3, 0.3, 0.3, 1.0];

// ガラスの断面色 [R, G, B, Alpha]
color_cut_glass    = [0.2, 0.4, 0.8, 1.0];

// 鉄球の断面色 [R, G, B, Alpha]
color_cut_steel    = [0.8, 0.8, 0.8, 1.0];


/* [鉄球（ステンレスボール）] */

// 鉄球の半径（直径12mmの場合は6）
ball_r     = 6;

// 鉄球のZ座標（高さ）
ball_z_pos = 22;


/* [ドリッパー（ガラス部分）] */

// 底の穴の半径
glass_hole_r         = 10.5;

// プラグ内側の上部半径
glass_plug_inner_r   = 12.5;

// 円錐上部の内側半径
glass_top_inner_r    = 51;

// 円錐上部の外側半径
glass_top_outer_r    = 53.5;

// 円錐全体の高さ
glass_total_h        = 78;


/* [ドリッパー・プラグ部分（Oリング状の膨らみ）] */

// プラグの縦幅（高さ）
plug_h     = 4;

// プラグの一番細い部分（根本）の半径
plug_min_r = 15;

// プラグの一番太い部分（膨らみ）の半径
plug_max_r = 16;


/* [台座（シリコンベース外側）] */

// 下部円筒の内側半径
base_bottom_inner_r  = 27;

// 下部円筒の外側半径
base_bottom_outer_r  = 30;

// 下部円筒の高さ
base_bottom_h        = 22;

// ツバ部分の半径
base_flange_r        = 50;

// ツバ部分の高さ
base_flange_h        = 22.5;

// くびれ下部の半径
base_neck_lower_r    = 48;

// くびれ下部の高さ
base_neck_lower_h    = 28;

// くびれの一番細い部分の半径
base_neck_narrow_r   = 35;

// くびれ上部の半径
base_neck_upper_r    = 27;

// くびれ上部の高さ
base_neck_upper_h    = 47;

// 上部開口部の外側半径
base_top_outer_r     = 30;

// 上部開口部の内側半径
base_top_inner_r     = 26.5;

// 全体の高さ
base_top_h           = 67;


/* [台座（シリコンベース内側機構）] */

// ガラスがハマる基準の高さ（Z座標）
mating_z             = 36.1;

// ボールが上下する空間の半径
chamber_inner_r      = 10.5;

// 空間の上端高さ
chamber_top_z        = 36;

// 空間の下端高さ
chamber_bottom_z     = 21;

// スイッチ底部の水抜け穴の半径
valve_seat_r         = 5;

// スイッチ底部の水抜け穴の高さ
valve_seat_z         = 17;

// 機構外側の斜め部分の半径
valve_chamber_out_r  = 18;

// 機構外側の中間高さ
valve_chamber_mid_z  = 22;

// 機構外側の上部半径
valve_chamber_top_r  = 21;


// ==========================================
// 🛠️ 内部計算とモジュール（通常はここから下は変更不要）
// ==========================================

// --- プラグの曲線を生成するための円弧計算 ---
plug_delta_r = plug_max_r - plug_min_r;
plug_half_h  = plug_h / 2;
// 3点を通る円弧の半径と中心を自動計算
arc_r = (pow(plug_half_h, 2) + pow(plug_delta_r, 2)) / (2 * plug_delta_r);
arc_center_r = plug_max_r - arc_r;

module cut_cube() {
    translate([-150, -100, -20]) cube([300, 100, 150]);
}

module render_silicone() {
    if (show_cross_section) {
        difference() { silicone_base(); color(color_cut_silicone) cut_cube(); }
    } else { silicone_base(); }
}

module render_glass() {
    if (show_cross_section) {
        difference() { glass_dripper(); color(color_cut_glass) cut_cube(); }
    } else { glass_dripper(); }
}

module render_steel() {
    if (show_cross_section) {
        difference() { steel_ball(); color(color_cut_steel) cut_cube(); }
    } else { steel_ball(); }
}

module scene() {
    translate([-110, 0, 0]) {
        render_silicone();
        translate([0, 0, ball_z_pos]) render_steel(); 
    }
    translate([0, 0, 0]) {
        render_silicone();
        translate([0, 0, mating_z]) render_glass();
        translate([0, 0, ball_z_pos]) render_steel(); 
    }
    translate([110, 0, 0]) {
        translate([0, 0, mating_z]) render_glass();
    }
}

// 実行
scene();

module steel_ball() {
    color([0.7, 0.7, 0.7, 1.0])
    sphere(r=ball_r, $fn=100);
}

module glass_dripper() {
    color([0.6, 0.8, 1.0, 0.4])
    rotate_extrude($fn=100)
    polygon(concat(
        // 内側
        [
            [glass_hole_r, 0],
            [glass_plug_inner_r, plug_h],
            [glass_top_inner_r, glass_total_h],
            [glass_top_outer_r, glass_total_h]
        ],
        // 外側根本
        [
            [plug_min_r, plug_h]
        ],
        // 計算されたカーブの生成
        [ for (t = [10:-1:0]) 
            let(
                z_val = plug_h * (t/10),
                r_val = arc_center_r + sqrt(pow(arc_r, 2) - pow(z_val - plug_half_h, 2))
            ) 
            [r_val, z_val] 
        ]
    ));
}

module silicone_base() {
    color([0.1, 0.1, 0.1, 0.9])
    rotate_extrude($fn=120)
    polygon(concat(
        // 外側
        [
            [base_bottom_inner_r, 0],
            [base_bottom_outer_r, 0],
            [base_bottom_outer_r, base_bottom_h],
            [base_flange_r, base_flange_h],
            [base_neck_lower_r, base_neck_lower_h],
            [base_neck_narrow_r, base_neck_lower_h],
            [base_neck_upper_r, base_neck_upper_h],
            [base_top_outer_r, base_top_h],
            [base_top_inner_r, base_top_h]
        ],
        // 内側上部
        [
            [plug_min_r, mating_z + plug_h]
        ],
        // 計算された溝のカーブ生成
        [ for (t = [10:-1:0]) 
            let(
                z_rel = plug_h * (t/10),
                z_val = mating_z + z_rel,
                r_val = arc_center_r + sqrt(pow(arc_r, 2) - pow(z_rel - plug_half_h, 2))
            ) 
            [r_val, z_val] 
        ],
        // 内側機構部
        [
            [chamber_inner_r, chamber_top_z],
            [chamber_inner_r, chamber_bottom_z],
            [valve_seat_r, valve_seat_z],
            [chamber_inner_r, valve_seat_z],
            [valve_chamber_out_r, valve_chamber_mid_z],
            [valve_chamber_top_r, chamber_top_z],
            [base_bottom_inner_r, base_bottom_h]
        ]
    ));
}
