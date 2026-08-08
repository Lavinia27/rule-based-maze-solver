import tkinter as tk
from tkinter import messagebox
import clips

# culori interfata
color_liber = "#ffffff"
color_zid = "#333333"
color_start = "#4caf50"
color_iesire = "#f44336"
color_agent = "#2196f3"
color_vizitat = "#bbdefb"
color_infundat = "#ff9800"

# harti pentru cele 6 niveluri (0 = liber, 1 = zid)
niveluri = [
    # nivel 1: 3x3
    [[0, 0, 0],
     [0, 1, 0],
     [0, 0, 0]],
    
    # nivel 2: 4x4
    [[0, 0, 0, 0],
     [0, 1, 1, 0],
     [0, 0, 0, 0],
     [1, 0, 1, 0]],
    
    # nivel 3: 5x5
    [[0, 0, 1, 0, 0],
     [1, 0, 0, 0, 1],
     [1, 1, 0, 1, 0],
     [1, 0, 0, 1, 0],
     [1, 0, 0, 0, 0]],
    
    # nivel 4: 6x6
    [[0, 0, 0, 1, 0, 0],
     [0, 1, 0, 0, 0, 0],
     [0, 1, 1, 1, 0, 0],
     [0, 0, 0, 1, 0, 1],
     [1, 1, 0, 0, 0, 0],
     [0, 0, 0, 1, 0, 0]],
    
    # nivel 5: 7x7
    [[0, 0, 0, 0, 1, 0, 0],
     [1, 1, 0, 0, 1, 0, 0],
     [0, 0, 0, 1, 1, 0, 1],
     [0, 1, 0, 0, 0, 0, 0],
     [0, 1, 1, 1, 1, 0, 0],
     [0, 0, 0, 0, 0, 0, 0],
     [0, 0, 1, 1, 0, 1, 0]],
    
    # nivel 6: 8x8
    [[0, 0, 0, 0, 0, 0, 0, 0],
     [1, 1, 1, 0, 1, 1, 0, 0],
     [0, 0, 0, 0, 1, 0, 0, 1],
     [0, 1, 1, 0, 0, 0, 1, 0],
     [0, 0, 1, 0, 1, 0, 0, 0],
     [1, 0, 0, 0, 1, 1, 1, 0],
     [0, 0, 1, 0, 0, 0, 0, 0],
     [0, 0, 0, 1, 1, 0, 1, 0]]
]

class AplicatieLabirint:
    def __init__(self, root):
        self.root = root
        self.root.title("sistem expert - rezolvare labirint")
        self.nivel_curent = 0
        self.dimensiune_celula = 50
        
        self.start_poz = None
        self.iesire_poz = None
        
        self.env = clips.Environment()
        
        # incarcare reguli
        try:
            self.env.load("e3.clp")
        except Exception as e:
            messagebox.showerror("eroare", f"nu s-a putut incarca e3.clp: {e}")
            
        self.setup_gui()
        self.incarca_nivel()
        
    def setup_gui(self):
        # cadru informatii
        self.info_frame = tk.Frame(self.root)
        self.info_frame.pack(pady=10)
        
        self.label_status = tk.Label(self.info_frame, text="selecteaza punctul de start (click pe o celula alba)", font=("Arial", 12))
        self.label_status.pack()
        
        # panou desenare labirint
        self.canvas = tk.Canvas(self.root, bg="gray")
        self.canvas.pack(padx=20, pady=10)
        self.canvas.bind("<Button-1>", self.on_click_celula)
        
        # cadru butoane
        self.btn_frame = tk.Frame(self.root)
        self.btn_frame.pack(pady=10)
        
        self.btn_start = tk.Button(self.btn_frame, text="porneste agentul", state=tk.DISABLED, command=self.porneste_rezolvarea, font=("Arial", 12))
        self.btn_start.pack(side=tk.LEFT, padx=10)
        
        self.btn_continua = tk.Button(self.btn_frame, text="continua (nivel urmator)", state=tk.DISABLED, command=self.urmatorul_nivel, font=("Arial", 12))
        self.btn_continua.pack(side=tk.LEFT, padx=10)
        
    def incarca_nivel(self):
        self.harta = niveluri[self.nivel_curent]
        self.dimensiune = len(self.harta)
        
        self.start_poz = None
        self.iesire_poz = None
        
        self.canvas.config(width=self.dimensiune * self.dimensiune_celula, height=self.dimensiune * self.dimensiune_celula)
        self.deseneaza_harta()
        
        self.label_status.config(text=f"nivel {self.nivel_curent + 1}. selecteaza punctul de start.")
        self.btn_start.config(state=tk.DISABLED)
        self.btn_continua.config(state=tk.DISABLED)
        
    def deseneaza_harta(self):
        self.canvas.delete("all")
        for i in range(self.dimensiune):
            for j in range(self.dimensiune):
                x0 = j * self.dimensiune_celula
                y0 = i * self.dimensiune_celula
                x1 = x0 + self.dimensiune_celula
                y1 = y0 + self.dimensiune_celula
                
                culoare = color_liber
                if self.harta[i][j] == 1:
                    culoare = color_zid
                
                self.canvas.create_rectangle(x0, y0, x1, y1, fill=culoare, outline="black", tags=f"celula_{i}_{j}")

    def on_click_celula(self, event):
        j = event.x // self.dimensiune_celula
        i = event.y // self.dimensiune_celula
        
        # verificare limite panou
        if i < 0 or i >= self.dimensiune or j < 0 or j >= self.dimensiune:
            return
            
        if self.harta[i][j] == 1:
            return # ignoram click pe zid
            
        if self.start_poz is None:
            self.start_poz = (i, j)
            self.coloreaza_celula(i, j, color_start)
            self.label_status.config(text="selecteaza punctul de iesire.")
        elif self.iesire_poz is None and (i, j) != self.start_poz:
            self.iesire_poz = (i, j)
            self.coloreaza_celula(i, j, color_iesire)
            self.label_status.config(text="apasa 'porneste agentul' pentru a gasi iesirea.")
            self.btn_start.config(state=tk.NORMAL)

    def coloreaza_celula(self, i, j, culoare):
        x0 = j * self.dimensiune_celula
        y0 = i * self.dimensiune_celula
        x1 = x0 + self.dimensiune_celula
        y1 = y0 + self.dimensiune_celula
        self.canvas.create_rectangle(x0, y0, x1, y1, fill=culoare, outline="black")

    def deseneaza_agent(self, i, j):
        x0 = j * self.dimensiune_celula + 10
        y0 = i * self.dimensiune_celula + 10
        x1 = x0 + self.dimensiune_celula - 20
        y1 = y0 + self.dimensiune_celula - 20
        self.canvas.delete("agent")
        self.canvas.create_oval(x0, y0, x1, y1, fill=color_agent, tags="agent")

    def extrage_fapte_clips(self):
        self.env.reset()
        
        # dimensiune labirint
        self.env.assert_string(f"(dimensiune-labirint {self.dimensiune} {self.dimensiune})")
        
        # start, agent, iesire, scop
        start_l, start_c = self.start_poz[0] + 1, self.start_poz[1] + 1
        ies_l, ies_c = self.iesire_poz[0] + 1, self.iesire_poz[1] + 1
        
        self.env.assert_string(f"(start {start_l} {start_c})")
        self.env.assert_string(f"(agent {start_l} {start_c})")
        self.env.assert_string(f"(iesire {ies_l} {ies_c})")
        self.env.assert_string("(scop avanseaza)")
        self.env.assert_string(f"(vizitat {start_l} {start_c})")
        
        # generare ziduri si celule libere
        for i in range(self.dimensiune):
            for j in range(self.dimensiune):
                l, c = i + 1, j + 1
                if self.harta[i][j] == 1:
                    self.env.assert_string(f"(zid {l} {c})")
                else:
                    self.env.assert_string(f"(liber {l} {c})")

    def porneste_rezolvarea(self):
        self.btn_start.config(state=tk.DISABLED)
        self.label_status.config(text="agentul cauta drumul...")
        self.extrage_fapte_clips()
        l, c = self.start_poz # desenare agent la start
        self.deseneaza_agent(l, c)
        self.canvas.update()
        self.root.after(500, self.ruleaza_pas)#  întârziere înainte de prima mutare

    def ruleaza_pas(self):
        rezultat = self.env.run(1)
        
        # colorare traseu parcurs si fundaturi
        for fact in self.env.facts():
            nume = fact.template.name
            if nume == 'vizitat':
                l = int(fact[0]) - 1
                c = int(fact[1]) - 1
                if (l, c) != self.start_poz and (l, c) != self.iesire_poz:
                    self.coloreaza_celula(l, c, color_vizitat)
            elif nume == 'drum_infundat':
                l = int(fact[0]) - 1
                c = int(fact[1]) - 1
                if (l, c) != self.start_poz and (l, c) != self.iesire_poz:
                    self.coloreaza_celula(l, c, color_infundat)
                    
        # desenare agent pe pozitia curenta
        scop_atins = False
        for fact in self.env.facts():
            if fact.template.name == 'agent':
                l = int(fact[0]) - 1
                c = int(fact[1]) - 1
                self.deseneaza_agent(l, c)
            elif fact.template.name == 'scop' and fact[0] == 'gasit-iesire':
                scop_atins = True
                
        self.canvas.update()
        
        # verificare oprire
        if scop_atins:
            self.label_status.config(text="succes! agentul a gasit iesirea.")
            if self.nivel_curent < 5:
                self.btn_continua.config(state=tk.NORMAL)
            else:
                self.label_status.config(text="ai completat toate nivelurile!")
            return

        if rezultat > 0:
            # intarziere 800 ms pt animatie
            self.root.after(800, self.ruleaza_pas)
        else:
            self.label_status.config(text="sistemul s-a oprit (fundatura fara solutie).")
            self.btn_continua.config(state=tk.NORMAL)

    def urmatorul_nivel(self):
        if self.nivel_curent < 5:
            self.nivel_curent += 1
            self.incarca_nivel()

if __name__ == "__main__":
    root = tk.Tk()
    app = AplicatieLabirint(root)
    root.mainloop()