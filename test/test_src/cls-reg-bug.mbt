fn h(p: (Int, Int, Int, Int, Int, Int, Int, Int, Int, Int)) -> Int {
    let (v1, v2, v3, v4, v5, v6, v7, v8, v9, v10) = p;
    fn g(z: Int) -> Int {
        let r = v1 + v2 + v3 + v4 + v5 + v6 + v7 + v8 + v9 + v10;
        if not(z <= 0) {
            r
        } else {
            g(-z)
        }
    };
    g(1)
};

fn main {
    let t1 = print_int(h((1, 2, 3, 4, 5, 6, 7, 8, 9, 10)));
    ()
};