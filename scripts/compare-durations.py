import ROOT
from ROOT import TH1D, TCanvas

with open('d1.dat') as f:
  D1=f.readlines()

with open('d2.dat') as f:
  D2=f.readlines()

with open('d3.dat') as f:
  D3=f.readlines()


h=[]
h.append(TH1D("h1", "Sample 1", 100,0,2))
for x in D1:
  h[0].Fill(float(x))

h.append(TH1D("h2", "Sample 2", 100,0,2))
for x in D2:
  h[1].Fill(float(x))

h.append(TH1D("h3", "Sample 3", 100,0,2))
for x in D3:
  h[2].Fill(float(x))

c1 = ROOT.TCanvas("c1","SALOME",800,650)
c1.Divide(1,3)
for i in range(1,4,1):
    c1.cd(i)
    h[i-1].Draw()
