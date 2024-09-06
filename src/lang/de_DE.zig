pub const prompt = "Kundenverwaltung: ";
pub const shutdown_prompt = "\nBeende Programm!\n";
pub const cmd = struct {
    pub const help = struct {
        pub const quit = "quit, bye       Schließt das Programm";
    };
};

pub const tokens = struct {
    pub const quit = "beende";
    pub const bye = quit;
    pub const help = "hilfe";
    pub const search = "suche";
    pub const name = "name";
    pub const description = "beschreibung";
    pub const email = "email";
    pub const tel = "tel";
    pub const client = "kunde";
    pub const order = "auftrag";
    pub const new = "neu";
};
