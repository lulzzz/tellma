import { Component, Input, OnInit } from '@angular/core';
import { DetailsBaseComponent } from '~/app/shared/details-base/details-base.component';
import { Lookup, LookupForSave } from '~/app/data/entities/lookup';
import { addToWorkspace } from '~/app/data/util';
import { tap } from 'rxjs/operators';
import { ReportStore, WorkspaceService } from '~/app/data/workspace.service';
import { ApiService } from '~/app/data/api.service';
import { TranslateService } from '@ngx-translate/core';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';
import {
  DefinitionReportDefinitionForClient, LookupDefinitionForClient, ReportDefinitionForClient
} from '~/app/data/dto/definitions-for-client';
import { ReportView } from '../report-results/report-results.component';

@Component({
  selector: 't-lookups-details',
  templateUrl: './lookups-details.component.html',
  styles: []
})
export class LookupsDetailsComponent extends DetailsBaseComponent implements OnInit {

  private lookupsApi = this.api.lookupsApi(null, this.notifyDestruct$); // for intellisense
  private _definitionId: number;

  @Input()
  public set definitionId(t: number) {
    if (this._definitionId !== t) {
      this._definitionId = t;
      this.lookupsApi = this.api.lookupsApi(t, this.notifyDestruct$);
    }
  }

  public get definitionId(): number {
    return this._definitionId;
  }

  @Input()
  previewDefinition: LookupDefinitionForClient; // Used in preview mode

  public expand = '';

  constructor(
    private workspace: WorkspaceService, private api: ApiService, private translate: TranslateService,
    private router: Router, private route: ActivatedRoute) {
    super();
  }

  ngOnInit() {
    this.route.paramMap.subscribe((params: ParamMap) => {
      // This triggers changes on the screen

      if (this.isScreenMode) {

        const definitionId = +params.get('definitionId');

        if (!definitionId || !this.ws.definitions.Lookups[definitionId]) {
          this.router.navigate(['page-not-found'], { relativeTo: this.route.parent, replaceUrl: true });
        }

        if (this.definitionId !== definitionId) {
          this.definitionId = definitionId;
        }
      }
    });
  }

  get view(): string {
    return `lookups/${this.definitionId}`;
  }

  private get definition(): LookupDefinitionForClient {
    return this.previewDefinition || (!!this.definitionId ? this.ws.definitions.Lookups[this.definitionId] : null);
  }

  // UI Binding

  public get found(): boolean {
    return !!this.definition;
  }

  create = () => {
    const result: LookupForSave = {};
    if (this.ws.isPrimaryLanguage) {
      result.Name = this.initialText;
    } else if (this.ws.isSecondaryLanguage) {
      result.Name2 = this.initialText;
    } else if (this.ws.isTernaryLanguage) {
      result.Name3 = this.initialText;
    }
    return result;
  }

  public get ws() {
    return this.workspace.currentTenant;
  }

  public onActivate = (model: Lookup): void => {
    if (!!model && !!model.Id) {
      this.lookupsApi.activate([model.Id], { returnEntities: true, expand: this.expand }).pipe(
        tap(res => addToWorkspace(res, this.workspace))
      ).subscribe({ error: this.details.handleActionError });
    }
  }

  public onDeactivate = (model: Lookup): void => {
    if (!!model && !!model.Id) {
      this.lookupsApi.deactivate([model.Id], { returnEntities: true, expand: this.expand }).pipe(
        tap(res => addToWorkspace(res, this.workspace))
      ).subscribe({ error: this.details.handleActionError });
    }
  }

  public onEditDefinition = (_: Lookup) => {
    const ws = this.workspace;
    ws.isEdit = true;
    this.router.navigate(['../../../lookup-definitions', this.definitionId], { relativeTo: this.route })
      .then(success => {
        if (!success) {
          delete ws.isEdit;
        }
      })
      .catch(() => delete ws.isEdit);
  }

  public showActivate = (model: Lookup) => !!model && !model.IsActive;
  public showDeactivate = (model: Lookup) => !!model && model.IsActive;
  public showEditDefinition = (_: Lookup) => this.ws.canDo('lookup-definitions', 'Update', null);

  public canActivateDeactivateItem = (model: Lookup) => this.ws.canDo(this.view, 'IsActive', model.Id);

  public activateDeactivateTooltip = (model: Lookup) => this.canActivateDeactivateItem(model) ? '' :
    this.translate.instant('Error_AccountDoesNotHaveSufficientPermissions')

  public get masterCrumb(): string {
    return this.ws.getMultilingualValueImmediate(this.definition, 'TitlePlural');
  }

  public showTabs(isEdit: boolean, model: Lookup): boolean {
    return this.reports.length > 0 && this.showReports(isEdit, model);
  }

  // Embedded Reports

  public showReports(isEdit: boolean, model: Lookup) {
    return !!model && !!model.Id;
  }

  public get reports(): DefinitionReportDefinitionForClient[] {
    return this.definition.ReportDefinitions;
  }

  public reportDefinition(e: DefinitionReportDefinitionForClient): ReportDefinitionForClient {
    return this.ws.definitions.Reports[e.ReportDefinitionId];
  }

  public reportTitle(e: DefinitionReportDefinitionForClient): string {
    return this.ws.getMultilingualValueImmediate(e, 'Name') ||
      this.ws.getMultilingualValueImmediate(this.reportDefinition(e), 'Title')
      || this.translate.instant('Untitled');
  }

  public state(e: DefinitionReportDefinitionForClient): ReportStore {
    const stateKey = `lookups_details_${this.definitionId}_${e.ReportDefinitionId}`;

    const rs = this.workspace.currentTenant.reportState;
    if (!rs[stateKey]) {
      rs[stateKey] = new ReportStore();
    }

    return rs[stateKey];
  }

  public reportView(e: DefinitionReportDefinitionForClient): ReportView {
    const reportDef = this.reportDefinition(e);
    return !!reportDef && !!reportDef.Chart && reportDef.DefaultsToChart ? ReportView.chart : ReportView.pivot;
  }

  private get activeTabKey(): string {
    return `lookups_details_${this.definitionId}_activeTab`;
  }

  public get activeTab(): string {
    const key = this.activeTabKey;
    const miscState = this.ws.miscState;
    if (!miscState[key]) {
      if (this.reports.length > 0) {
        miscState[key] = this.reports[0].ReportDefinitionId;
      } else {
        miscState[key] = '<unknown>';
      }
    }

    return miscState[key];
  }

  public set activeTab(v: string) {
    this.ws.miscState[this.activeTabKey] = v;
  }

  public onExpandReport(reportId: number, model: Lookup) {
    this.router.navigate(['../../../report', reportId, { id: model.Id }], { relativeTo: this.route });
  }
}
